import SwiftUI
import AuthenticationServices

struct AccountView: View {
    @State private var authService = AuthService.shared
    @State private var syncService = CloudSyncService.shared
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var isSignUp = false
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var showDeleteConfirmation = false
    @State private var currentNonce: String?
    @Environment(\.dismiss) private var dismiss

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
                let nonce = AppleSignInHelper.randomNonceString()
                currentNonce = nonce
                request.requestedScopes = [.fullName, .email]
                request.nonce = AppleSignInHelper.sha256(nonce)
            } onCompletion: { result in
                Task { await handleAppleSignIn(result) }
            }
            .signInWithAppleButtonStyle(.whiteOutline)
            .frame(height: 50)
        } header: {
            ChronirText("Quick Sign In", style: .labelLarge, color: ColorTokens.textSecondary)
        }
        .listRowBackground(ColorTokens.surfaceCard)

        Section {
            if isSignUp {
                TextField("Display Name", text: $displayName)
                    .textContentType(.name)
            }
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                #if os(iOS)
                .textInputAutocapitalization(.never)
                #endif
            SecureField("Password", text: $password)
                .textContentType(isSignUp ? .newPassword : .password)

            Button {
                Task { await performEmailAuth() }
            } label: {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text(isSignUp ? "Create Account" : "Sign In")
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(ColorTokens.primary)
                }
            }
            .disabled(isLoading || email.isEmpty || password.isEmpty)
        } header: {
            ChronirText("Email", style: .labelLarge, color: ColorTokens.textSecondary)
        }
        .listRowBackground(ColorTokens.surfaceCard)

        Section {
            Button {
                isSignUp.toggle()
                errorMessage = nil
            } label: {
                Text(isSignUp ? "Already have an account? Sign in" : "Don't have an account? Create one")
                    .chronirFont(.caption)
                    .foregroundStyle(ColorTokens.primary)
                    .frame(maxWidth: .infinity)
            }
        }
        .listRowBackground(ColorTokens.surfaceCard)
    }

    // MARK: - Auth Actions

    private func performEmailAuth() async {
        isLoading = true
        defer { isLoading = false }

        do {
            if isSignUp {
                try await authService.signUp(email: email, password: password, displayName: displayName)
            } else {
                try await authService.signIn(email: email, password: password)
            }
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
}

#Preview("Signed Out") {
    NavigationStack {
        AccountView()
    }
}
