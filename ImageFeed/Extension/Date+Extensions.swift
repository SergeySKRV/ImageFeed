import Foundation

// MARK: - Date Extension

extension Date {
    
    // MARK: - Formatters
    
    static let dayMonthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
    }()
    
    // MARK: - Formatting Methods
    
    func formattedForImageCell() -> String {
        return Date.dayMonthYearFormatter.string(from: self)
    }
}
