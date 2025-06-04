import Foundation

protocol ProfileLogoutServiceProtocol {
    func logout()
}

final class ProfileLogoutServiceStub: ProfileLogoutServiceProtocol {
    private(set) var logoutCalled = false
    
    func logout() {
        logoutCalled = true
    }
}
