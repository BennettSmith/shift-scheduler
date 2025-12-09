import Foundation

// MARK: - Shared Boundary-Local Types
// These types are defined in the Application layer to avoid leaking Domain types through boundaries.
// Each enum mirrors a corresponding Domain enum but is independent of the Domain module.

// MARK: - User & Role Types

/// User role type for boundary objects (Application layer)
public enum UserRoleType: Sendable, Equatable {
    case scout
    case parent
    case scoutmaster
    case assistantScoutmaster
}

/// Account status type for boundary objects
public enum AccountStatusType: Sendable, Equatable {
    case pending
    case active
    case inactive
    case deactivated
}

// MARK: - Assignment Types

/// Participant type for boundary objects (scout or parent assignment)
public enum ParticipantType: Sendable, Equatable {
    case scout
    case parent
}

/// Assignment type value for boundary objects
public enum AssignmentTypeValue: Sendable, Equatable {
    case scout
    case parent
}

/// Assignment status type for boundary objects
public enum AssignmentStatusType: Sendable, Equatable {
    case pending
    case confirmed
    case cancelled
    case completed
}

// MARK: - Shift Types

/// Shift status type for boundary objects
public enum ShiftStatusType: Sendable, Equatable {
    case draft
    case published
    case cancelled
    case completed
}

/// Staffing status type for boundary objects
public enum StaffingStatusType: Sendable, Equatable {
    case empty
    case partial
    case full
}

// MARK: - Attendance Types

/// Check-in method type for boundary objects
public enum CheckInMethodType: Sendable, Equatable {
    case qrCode
    case manual
    case adminOverride
}

/// Attendance status type for boundary objects
public enum AttendanceStatusType: Sendable, Equatable {
    case pending
    case checkedIn
    case checkedOut
    case noShow
    case excused
}

// MARK: - Messaging Types

/// Message priority type for boundary objects
public enum MessagePriorityType: Sendable, Equatable {
    case low
    case normal
    case high
    case urgent
}

/// Target audience type for boundary objects
public enum TargetAudienceType: Sendable, Equatable {
    case all
    case scouts
    case parents
    case leadership
    case household
    case individual
}

// MARK: - Season Types

/// Season status type for boundary objects
public enum SeasonStatusType: Sendable, Equatable {
    case draft
    case active
    case completed
    case archived
}

// MARK: - Geographic Types

/// Geographic coordinate for boundary objects
public struct Coordinate: Sendable, Equatable {
    public let latitude: Double
    public let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
