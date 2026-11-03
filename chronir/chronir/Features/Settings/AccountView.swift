import SwiftUI
import SwiftData
import AuthenticationServices

struct AccountView: View {
    @State private var authService = AuthService.shared
    @State private var syncService = CloudSyncService.shared
    @State private var alert: AccountAlert?
    @State private var isLoading = false
    @State private var showDeleteConfirmation = false
    @State private var currentNonce: String?
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme

    private struct AccountAlert: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }

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
        .alert(
            alert?.title ?? "",
            isPresented: Binding(
                get: { alert != nil },
                set: { if !$0 { alert = nil } }
            ),
            presenting: alert
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { alert in
            Text(alert.message)
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
            Text("Account")
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
            Text("Sync")
        }
        .listRowBackground(ColorTokens.surfaceCard)

        Section {
            Button {
                do {
                    try authService.signOut()
                } catch {
                    alert = AccountAlert(title: "Couldn't sign out", message: error.localizedDescription)
                }
            } label: {
                ChronirText("Sign Out", style: .bodyPrimary, color: ColorTokens.primary)
            }
            .disabled(isLoading)

            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                HStack {
                    ChronirText(
                        isLoading ? "Deleting Account\u{2026}" : "Delete Account",
                        style: .bodyPrimary,
                        color: ColorTokens.textError
                    )
                    Spacer()
                    if isLoading {
                        ProgressView()
                    }
                }
            }
            .disabled(isLoading)
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
                        alert = AccountAlert(
                            title: "Account deleted",
                            message: "Your account and cloud data were deleted. Alarms on this iPhone keep working."
                        )
                    } catch {
                        alert = AccountAlert(title: "Couldn't delete account", message: error.localizedDescription)
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
                    color: ColorTokens.textSecondary
                )
            case .offline:
                ChronirText("Offline", style: .bodySecondary, color: ColorTokens.textWarning)
            case .error(let msg):
                ChronirText(msg, style: .bodySmall, color: ColorTokens.textError)
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
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .frame(height: signInButtonHeight)
            .clipShape(.rect(cornerRadius: RadiusTokens.md))
            .disabled(isLoading)

            // Neutral text button: no Google "G" asset ships in the repo, and an SF Symbol stand-in
            // would violate Google's branding rules. Matches the Apple button's size and shape.
            Button {
                Task { await handleGoogleSignIn() }
            } label: {
                Text("Sign in with Google")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(ColorTokens.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: signInButtonHeight)
                    .background(ColorTokens.surfaceElevated, in: .rect(cornerRadius: RadiusTokens.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: RadiusTokens.md)
                            .strokeBorder(ColorTokens.textSecondary, lineWidth: 1)
                    )
                    .contentShape(.rect(cornerRadius: RadiusTokens.md))
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
        } header: {
            Text("Sign In")
        } footer: {
            Text("Sign in to back up your alarms and sync them across devices.")
        }
        .listRowBackground(ColorTokens.surfaceCard)

        if isLoading {
            Section {
                ProgressView("Signing in\u{2026}")
                    .frame(maxWidth: .infinity)
            }
            .listRowBackground(ColorTokens.surfaceCard)
        }
    }

    /// Apple's recommended Sign in with Apple height; both sign-in buttons share it.
    @ScaledMetric(relativeTo: .title3) private var signInButtonHeight: CGFloat = 50

    // MARK: - Auth Actions

    private func handleGoogleSignIn() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.signInWithGoogle()
            await performInitialSync()
        } catch {
            alert = AccountAlert(title: "Couldn't sign in with Google", message: error.localizedDescription)
        }
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) async {
        switch result {
        case .success(let authorization):
            guard let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let nonce = currentNonce else {
                alert = AccountAlert(title: "Couldn't sign in with Apple", message: "Try again.")
                return
            }
            isLoading = true
            defer { isLoading = false }
            do {
                try await authService.signInWithApple(credential: appleCredential, nonce: nonce)
                await performInitialSync()
            } catch {
                alert = AccountAlert(title: "Couldn't sign in with Apple", message: error.localizedDescription)
            }
        case .failure(let error):
            // User cancelled is not an error
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                alert = AccountAlert(title: "Couldn't sign in with Apple", message: error.localizedDescription)
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

#Preview("Signed Out, Light") {
    NavigationStack {
        AccountView()
    }
    .preferredColorScheme(.light)
}

#Preview("Signed Out, Dark") {
    NavigationStack {
        AccountView()
    }
    .preferredColorScheme(.dark)
}
