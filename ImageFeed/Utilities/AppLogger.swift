import Foundation

final class AppLogger {
    
    enum Level: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
    }

    static func log(level: Level, _ message: String, in caller: String = #function) {
        print("[\(level.rawValue)] [$caller]: $message)")
    }

    static func error(_ error: Error, data: Data? = nil, in caller: String = #function) {
        if let data = data, let _ = String(data: data, encoding: .utf8) {
            log(level: .error, "$error.localizedDescription): $string)", in: caller)
        } else {
            log(level: .error, error.localizedDescription, in: caller)
        }
    }

    static func debug(_ message: String, in caller: String = #function) {
        log(level: .debug, message, in: caller)
    }

    static func info(_ message: String, in caller: String = #function) {
        log(level: .info, message, in: caller)
    }

    static func warning(_ message: String, in caller: String = #function) {
        log(level: .warning, message, in: caller)
    }
}
