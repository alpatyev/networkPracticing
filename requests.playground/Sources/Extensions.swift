import Foundation

// MARK: - Extension for date formatting

public extension Date {
    func string(with format: String ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
