import Foundation

// MARK: - ProfileLogoutServiceProtocol

protocol ProfileLogoutServiceProtocol {
    func logout()
}

// MARK: - ProfileLogoutServiceStub

final class ProfileLogoutServiceStub: ProfileLogoutServiceProtocol {
    private(set) var logoutCalled = false
    
    func logout() {
        logoutCalled = true
    }
}
