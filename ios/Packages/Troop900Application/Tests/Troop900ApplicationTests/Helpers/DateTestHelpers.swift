import Foundation

/// Utilities for creating consistent test dates
public enum DateTestHelpers {
    
    /// Calendar configured for testing (UTC timezone)
    public static let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        return cal
    }()
    
    /// Creates a date from year, month, day components
    /// - Parameters:
    ///   - year: The year
    ///   - month: The month (1-12)
    ///   - day: The day (1-31)
    /// - Returns: A Date in UTC timezone
    public static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 0
        components.minute = 0
        components.second = 0
        return calendar.date(from: components)!
    }
    
    /// Creates a date with time from components
    /// - Parameters:
    ///   - year: The year
    ///   - month: The month (1-12)
    ///   - day: The day (1-31)
    ///   - hour: The hour (0-23)
    ///   - minute: The minute (0-59)
    /// - Returns: A Date in UTC timezone
    public static func dateTime(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = 0
        return calendar.date(from: components)!
    }
    
    /// Returns a date in the past (yesterday)
    public static var yesterday: Date {
        calendar.date(byAdding: .day, value: -1, to: Date())!
    }
    
    /// Returns a date in the future (tomorrow)
    public static var tomorrow: Date {
        calendar.date(byAdding: .day, value: 1, to: Date())!
    }
    
    /// Returns a date one week from now
    public static var nextWeek: Date {
        calendar.date(byAdding: .day, value: 7, to: Date())!
    }
    
    /// Returns a date one hour ago
    public static var oneHourAgo: Date {
        calendar.date(byAdding: .hour, value: -1, to: Date())!
    }
    
    /// Returns a date one hour from now
    public static var oneHourFromNow: Date {
        calendar.date(byAdding: .hour, value: 1, to: Date())!
    }
    
    /// Returns a date 15 minutes ago (within check-in window)
    public static var fifteenMinutesAgo: Date {
        calendar.date(byAdding: .minute, value: -15, to: Date())!
    }
    
    /// Returns a time-only date for template times (hour and minute only)
    /// - Parameters:
    ///   - hour: The hour (0-23)
    ///   - minute: The minute (0-59)
    /// - Returns: A Date representing the time
    public static func time(_ hour: Int, _ minute: Int = 0) -> Date {
        dateTime(2024, 1, 1, hour, minute)
    }
    
    /// Creates a date relative to now
    /// - Parameters:
    ///   - days: Days to add (negative for past)
    ///   - hours: Hours to add (negative for past)
    ///   - minutes: Minutes to add (negative for past)
    /// - Returns: The calculated date
    public static func relativeDate(days: Int = 0, hours: Int = 0, minutes: Int = 0) -> Date {
        var date = Date()
        if days != 0 {
            date = calendar.date(byAdding: .day, value: days, to: date)!
        }
        if hours != 0 {
            date = calendar.date(byAdding: .hour, value: hours, to: date)!
        }
        if minutes != 0 {
            date = calendar.date(byAdding: .minute, value: minutes, to: date)!
        }
        return date
    }
    
    /// Reference date for consistent testing (Dec 15, 2024)
    public static var referenceDate: Date {
        date(2024, 12, 15)
    }
    
    /// Reference start of season (Nov 29, 2024)
    public static var seasonStartDate: Date {
        date(2024, 11, 29)
    }
    
    /// Reference end of season (Dec 24, 2024)
    public static var seasonEndDate: Date {
        date(2024, 12, 24)
    }
}

// MARK: - Convenience Extensions

public extension Date {
    /// Returns the start of day for this date
    var startOfDay: Date {
        DateTestHelpers.calendar.startOfDay(for: self)
    }
    
    /// Adds days to the date
    func addingDays(_ days: Int) -> Date {
        DateTestHelpers.calendar.date(byAdding: .day, value: days, to: self)!
    }
    
    /// Adds hours to the date
    func addingHours(_ hours: Int) -> Date {
        DateTestHelpers.calendar.date(byAdding: .hour, value: hours, to: self)!
    }
}
