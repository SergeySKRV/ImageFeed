import Foundation

extension Date {
    static let dayMonthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
    }()
    
    func formattedForImageCell() -> String {
        return Date.dayMonthYearFormatter.string(from: self)
    }
}
