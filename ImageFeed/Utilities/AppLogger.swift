import Foundation

// MARK: - AppLogger Class

final class AppLogger {
    
    // MARK: - Error Logging
    
    static func error(_ error: Error, data: Data? = nil, in caller: String = #function) {
        if let data = data, let string = String(data: data, encoding: .utf8) {
            print("ERROR: [\(caller)]: \(error.localizedDescription) with DATA: \(string)")
        } else {
            print("ERROR: [\(caller)]: \(error.localizedDescription)")
        }
    }
    
    static func error(_ message: String, in caller: String = #function) {
        print("ERROR: [\(caller)]: \(message)")
    }
    
    // MARK: - Info Logging
    
    static func info(_ message: String, in caller: String = #function) {
        print("INFO: [\(caller)]: \(message)")
    }
}
