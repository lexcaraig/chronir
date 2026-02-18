import Foundation
import FirebaseAuth
import AuthenticationServices
import Observation

protocol AuthServiceProtocol: Sendable {
    func signIn(email: String, password: String) async throws -> UserProfile
    func signUp(email: String, password: String, displayName: String) async throws -> UserProfile
    func signInWithApple(credential: ASAuthorizationAppleIDCredential, nonce: String) async throws -> UserProfile
    func signOut() throws
    func currentUser() -> UserProfile?
    func deleteAccount() async throws
}

@Observable
final class AuthService: AuthServiceProtocol, @unchecked Sendable {
    static let shared = AuthService()

    private(set) var userProfile: UserProfile?
    private(set) var isSignedIn: Bool = false

    private var hasRestoredSession = false

    private init() {}

    /// Call after FirebaseApp.configure() to restore any existing auth session.
    func restoreSessionIfNeeded() {
        guard !hasRestoredSession else { return }
        hasRestoredSession = true
        if let firebaseUser = Auth.auth().currentUser {
            userProfile = UserProfile(from: firebaseUser)
            isSignedIn = true
        }
    }

    // MARK: - Email Auth

    @discardableResult
    func signIn(email: String, password: String) async throws -> UserProfile {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        let profile = UserProfile(from: result.user)
        await MainActor.run {
            self.userProfile = profile
            self.isSignedIn = true
        }
        return profile
    }

    @discardableResult
    func signUp(email: String, password: String, displayName: String) async throws -> UserProfile {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        try await changeRequest.commitChanges()
        let profile = UserProfile(from: result.user)
        await MainActor.run {
            self.userProfile = profile
            self.isSignedIn = true
        }
        return profile
    }

    // MARK: - Apple Sign In

    @discardableResult
    func signInWithApple(credential: ASAuthorizationAppleIDCredential, nonce: String) async throws -> UserProfile {
        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            throw AuthError.invalidCredential
        }

        let firebaseCredential = OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: tokenString,
            rawNonce: nonce
        )
        let result = try await Auth.auth().signIn(with: firebaseCredential)

        // Apple only provides name on first sign-in
        if let fullName = credential.fullName {
            let displayName = [fullName.givenName, fullName.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            if !displayName.isEmpty, result.user.displayName == nil {
                let changeRequest = result.user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                try? await changeRequest.commitChanges()
            }
        }

        let profile = UserProfile(from: result.user)
        await MainActor.run {
            self.userProfile = profile
            self.isSignedIn = true
        }
        return profile
    }

    // MARK: - Sign Out

    func signOut() throws {
        try Auth.auth().signOut()
        userProfile = nil
        isSignedIn = false
    }

    // MARK: - Current User

    func currentUser() -> UserProfile? {
        guard let firebaseUser = Auth.auth().currentUser else { return nil }
        return UserProfile(from: firebaseUser)
    }

    // MARK: - Account Deletion

    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.noUser
        }
        // Delete auth account first to verify recent authentication.
        // If this fails (e.g. requiresRecentLogin), no data is lost.
        try await user.delete()
        // Only delete cloud data after auth account is confirmed deleted
        try? await CloudSyncService.shared.deleteAllCloudData()
        await MainActor.run {
            self.userProfile = nil
            self.isSignedIn = false
        }
    }

    // MARK: - Errors

    enum AuthError: LocalizedError {
        case invalidCredential
        case noUser

        var errorDescription: String? {
            switch self {
            case .invalidCredential: return "Invalid sign-in credentials."
            case .noUser: return "No signed-in user."
            }
        }
    }
}

// MARK: - Apple Sign In Nonce Helpers

import CryptoKit

enum AppleSignInHelper {
    static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        guard errorCode == errSecSuccess else {
            preconditionFailure("Unable to generate secure random bytes: \(errorCode)")
        }
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - UserProfile Extension

extension UserProfile {
    init(from user: FirebaseAuth.User) {
        self.init(
            id: user.uid,
            displayName: user.displayName ?? "User",
            email: user.email ?? ""
        )
    }
}
