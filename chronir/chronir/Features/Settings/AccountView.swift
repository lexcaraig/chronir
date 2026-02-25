import SwiftUI
import SwiftData
import AuthenticationServices

struct AccountView: View {
    @State private var authService = AuthService.shared
    @State private var syncService = CloudSyncService.shared
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var showDeleteConfirmation = false
    @State private var currentNonce: String?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        List {
            if authService.isSignedIn {
                signedInContent
            } else {
                signInContent
            }
        }
        .scrollContentBackground(.hidden)
        .background(ColorTokens.backgroundPrimary)
        .navigationTitle(authService.isSignedIn ? "Account" : "Sign In")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    // MARK: - Signed In

    @ViewBuilder
    private var signedInContent: some View {
        Section {
            HStack {
                ChronirText("Email", style: .bodyPrimary)
                Spacer()
                ChronirText(
                    authService.userProfile?.email ?? "",
                    style: .bodySecondary,
                    color: ColorTokens.textSecondary
                )
            }
            HStack {
                ChronirText("Name", style: .bodyPrimary)
                Spacer()
                ChronirText(
                    authService.userProfile?.displayName ?? "",
                    style: .bodySecondary,
                    color: ColorTokens.textSecondary
                )
            }
        } header: {
            ChronirText("Account", style: .labelLarge, color: ColorTokens.textSecondary)
        }
        .listRowBackground(ColorTokens.surfaceCard)

        Section {
            syncStatusRow
            Button {
                Task { await performInitialSync() }
            } label: {
                HStack {
                    ChronirText("Sync Now", style: .bodyPrimary, color: ColorTokens.primary)
                    Spacer()
                    if syncService.syncState == .syncing {
                        ProgressView()
                    }
                }
            }
            .disabled(syncService.syncState == .syncing)
        } header: {
            ChronirText("Sync", style: .labelLarge, color: ColorTokens.textSecondary)
        }
        .listRowBackground(ColorTokens.surfaceCard)

        Section {
            Button {
                do {
                    try authService.signOut()
                } catch {
                    errorMessage = error.localizedDescription
                }
            } label: {
                ChronirText("Sign Out", style: .bodyPrimary, color: ColorTokens.primary)
            }

            Button {
                showDeleteConfirmation = true
            } label: {
                ChronirText("Delete Account", style: .bodyPrimary, color: ColorTokens.error)
            }
        }
        .listRowBackground(ColorTokens.surfaceCard)
        .confirmationDialog(
            "Delete your account and all cloud data? This cannot be undone.",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Account", role: .destructive) {
                Task {
                    isLoading = true
                    defer { isLoading = false }
                    do {
                        try await authService.deleteAccount()
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }

    private var syncStatusRow: some View {
        HStack {
            ChronirText("Status", style: .bodyPrimary)
            Spacer()
            switch syncService.syncState {
            case .idle:
                ChronirText("Not synced", style: .bodySecondary, color: ColorTokens.textSecondary)
            case .syncing:
                ProgressView()
            case .synced(let date):
                ChronirText(
                    "Synced \(date.formatted(.relative(presentation: .named)))",
                    style: .bodySecondary,
                    color: ColorTokens.success
                )
            case .offline:
                ChronirText("Offline", style: .bodySecondary, color: ColorTokens.warning)
            case .error(let msg):
                ChronirText(msg, style: .caption, color: ColorTokens.error)
            }
        }
    }

    // MARK: - Sign In

    @ViewBuilder
    private var signInContent: some View {
        Section {
            SignInWithAppleButton(.signIn) { request in
                guard let nonce = try? AppleSignInHelper.randomNonceString() else { return }
                currentNonce = nonce
                request.requestedScopes = [.fullName, .email]
                request.nonce = AppleSignInHelper.sha256(nonce)
            } onCompletion: { result in
                Task { await handleAppleSignIn(result) }
            }
            .signInWithAppleButtonStyle(.whiteOutline)
            .frame(height: 50)

            Button {
                Task { await handleGoogleSignIn() }
            } label: {
                HStack {
                    Image(systemName: "g.circle.fill")
                        .font(.title2)
                    Text("Sign in with Google")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .foregroundStyle(ColorTokens.textPrimary)
            }
            .disabled(isLoading)
        } header: {
            ChronirText("Sign In", style: .labelLarge, color: ColorTokens.textSecondary)
        }
        .listRowBackground(ColorTokens.surfaceCard)

        if isLoading {
            Section {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
            .listRowBackground(ColorTokens.surfaceCard)
        }
    }

    // MARK: - Auth Actions

    private func handleGoogleSignIn() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.signInWithGoogle()
            await performInitialSync()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) async {
        switch result {
        case .success(let authorization):
            guard let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let nonce = currentNonce else {
                errorMessage = "Apple Sign In failed."
                return
            }
            isLoading = true
            defer { isLoading = false }
            do {
                try await authService.signInWithApple(credential: appleCredential, nonce: nonce)
                await performInitialSync()
            } catch {
                errorMessage = error.localizedDescription
            }
        case .failure(let error):
            // User cancelled is not an error
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                errorMessage = error.localizedDescription
            }
        }
    }

    /// After sign-in, upload all local alarms to cloud and restore any remote-only alarms.
    private func performInitialSync() async {
        let descriptor = FetchDescriptor<Alarm>()
        guard let localAlarms = try? modelContext.fetch(descriptor) else { return }

        // Upload local alarms to cloud
        await syncService.uploadAllAlarms(localAlarms)

        // Pull remote alarms that don't exist locally and insert them
        guard let remotePayloads = try? await syncService.fetchAllRemoteAlarms() else { return }
        let localIDs = Set(localAlarms.map { $0.id.uuidString })
        let newPayloads = remotePayloads.filter { !localIDs.contains($0.id) }

        for payload in newPayloads {
            if let alarm = payload.toAlarm() {
                modelContext.insert(alarm)
            }
        }
        if !newPayloads.isEmpty {
            try? modelContext.save()
            try? await AlarmScheduler.shared.rescheduleAllAlarms()
        }
    }
}

#Preview("Signed Out") {
    NavigationStack {
        AccountView()
    }
}
