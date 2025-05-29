import Foundation

extension Date {
    static let imageCellDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
    }()
    
    func imageCellDateString() -> String {
        return Date.imageCellDateFormatter.string(from: self)
    }
}
