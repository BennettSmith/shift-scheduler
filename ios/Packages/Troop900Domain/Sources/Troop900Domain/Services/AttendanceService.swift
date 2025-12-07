import Foundation

/// Protocol for attendance-related remote operations (Cloud Functions).
public protocol AttendanceService: Sendable {
    /// Check in to a shift.
    /// - Parameter request: The check-in request.
    /// - Returns: The check-in result.
    func checkIn(request: CheckInServiceRequest) async throws -> CheckInServiceResponse
    
    /// Check out from a shift.
    /// - Parameters:
    ///   - assignmentId: The assignment's ID.
    ///   - notes: Optional notes about the shift.
    /// - Returns: The check-out result.
    func checkOut(assignmentId: String, notes: String?) async throws -> CheckOutServiceResponse
    
    /// Admin manual check-in (for fixing issues or late arrivals).
    /// - Parameter request: The admin check-in request.
    /// - Returns: The check-in result.
    func adminManualCheckIn(request: AdminCheckInRequest) async throws -> CheckInServiceResponse
    
    /// Admin manual check-out (for fixing issues or early departures).
    /// - Parameter request: The admin check-out request.
    /// - Returns: The check-out result.
    func adminManualCheckOut(request: AdminCheckOutRequest) async throws -> CheckOutServiceResponse
}

/// Request to check in to a shift.
public struct CheckInServiceRequest: Sendable, Codable {
    public let assignmentId: String
    public let shiftId: String
    public let qrCodeData: String?
    public let location: GeoLocation?
    
    public init(
        assignmentId: String,
        shiftId: String,
        qrCodeData: String?,
        location: GeoLocation?
    ) {
        self.assignmentId = assignmentId
        self.shiftId = shiftId
        self.qrCodeData = qrCodeData
        self.location = location
    }
}

/// Response from check-in operation.
public struct CheckInServiceResponse: Sendable, Codable {
    public let success: Bool
    public let attendanceRecordId: String
    public let checkInTime: Date
    
    public init(success: Bool, attendanceRecordId: String, checkInTime: Date) {
        self.success = success
        self.attendanceRecordId = attendanceRecordId
        self.checkInTime = checkInTime
    }
}

/// Response from check-out operation.
public struct CheckOutServiceResponse: Sendable, Codable {
    public let success: Bool
    public let checkOutTime: Date
    public let hoursWorked: Double
    
    public init(success: Bool, checkOutTime: Date, hoursWorked: Double) {
        self.success = success
        self.checkOutTime = checkOutTime
        self.hoursWorked = hoursWorked
    }
}

/// Request for admin to manually check in a user.
public struct AdminCheckInRequest: Sendable, Codable {
    public let assignmentId: String
    public let shiftId: String
    public let adminUserId: String
    public let overrideTime: Date?
    public let notes: String?
    
    public init(
        assignmentId: String,
        shiftId: String,
        adminUserId: String,
        overrideTime: Date?,
        notes: String?
    ) {
        self.assignmentId = assignmentId
        self.shiftId = shiftId
        self.adminUserId = adminUserId
        self.overrideTime = overrideTime
        self.notes = notes
    }
}

/// Request for admin to manually check out a user.
public struct AdminCheckOutRequest: Sendable, Codable {
    public let assignmentId: String
    public let adminUserId: String
    public let overrideTime: Date?
    public let notes: String?
    
    public init(
        assignmentId: String,
        adminUserId: String,
        overrideTime: Date?,
        notes: String?
    ) {
        self.assignmentId = assignmentId
        self.adminUserId = adminUserId
        self.overrideTime = overrideTime
        self.notes = notes
    }
}
