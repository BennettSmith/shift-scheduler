import Foundation
import Troop900Domain

/// Mock implementation of AttendanceService for testing
public final class MockAttendanceService: AttendanceService, @unchecked Sendable {
    
    // MARK: - Configurable Results
    
    public var checkInResult: Result<CheckInServiceResponse, Error>?
    public var checkOutResult: Result<CheckOutServiceResponse, Error>?
    public var adminManualCheckInResult: Result<CheckInServiceResponse, Error>?
    public var adminManualCheckOutResult: Result<CheckOutServiceResponse, Error>?
    
    // MARK: - Call Tracking
    
    public var checkInCallCount = 0
    public var checkInCalledWith: [CheckInServiceRequest] = []
    
    public var checkOutCallCount = 0
    public var checkOutCalledWith: [(assignmentId: AssignmentId, notes: String?)] = []
    
    public var adminManualCheckInCallCount = 0
    public var adminManualCheckInCalledWith: [AdminCheckInRequest] = []
    
    public var adminManualCheckOutCallCount = 0
    public var adminManualCheckOutCalledWith: [AdminCheckOutRequest] = []
    
    // MARK: - AttendanceService Implementation
    
    public func checkIn(request: CheckInServiceRequest) async throws -> CheckInServiceResponse {
        checkInCallCount += 1
        checkInCalledWith.append(request)
        
        if let result = checkInResult {
            return try result.get()
        }
        
        // Default success response
        return CheckInServiceResponse(
            success: true,
            attendanceRecordId: AttendanceRecordId(unchecked: "attendance-\(UUID().uuidString.prefix(8))"),
            checkInTime: Date()
        )
    }
    
    public func checkOut(assignmentId: AssignmentId, notes: String?) async throws -> CheckOutServiceResponse {
        checkOutCallCount += 1
        checkOutCalledWith.append((assignmentId, notes))
        
        if let result = checkOutResult {
            return try result.get()
        }
        
        // Default success response
        return CheckOutServiceResponse(
            success: true,
            checkOutTime: Date(),
            hoursWorked: 4.0
        )
    }
    
    public func adminManualCheckIn(request: AdminCheckInRequest) async throws -> CheckInServiceResponse {
        adminManualCheckInCallCount += 1
        adminManualCheckInCalledWith.append(request)
        
        if let result = adminManualCheckInResult {
            return try result.get()
        }
        
        // Default success response
        return CheckInServiceResponse(
            success: true,
            attendanceRecordId: AttendanceRecordId(unchecked: "attendance-\(UUID().uuidString.prefix(8))"),
            checkInTime: request.overrideTime ?? Date()
        )
    }
    
    public func adminManualCheckOut(request: AdminCheckOutRequest) async throws -> CheckOutServiceResponse {
        adminManualCheckOutCallCount += 1
        adminManualCheckOutCalledWith.append(request)
        
        if let result = adminManualCheckOutResult {
            return try result.get()
        }
        
        // Default success response
        return CheckOutServiceResponse(
            success: true,
            checkOutTime: request.overrideTime ?? Date(),
            hoursWorked: 4.0
        )
    }
    
    // MARK: - Test Helpers
    
    /// Resets all state and call tracking
    public func reset() {
        checkInResult = nil
        checkOutResult = nil
        adminManualCheckInResult = nil
        adminManualCheckOutResult = nil
        checkInCallCount = 0
        checkInCalledWith.removeAll()
        checkOutCallCount = 0
        checkOutCalledWith.removeAll()
        adminManualCheckInCallCount = 0
        adminManualCheckInCalledWith.removeAll()
        adminManualCheckOutCallCount = 0
        adminManualCheckOutCalledWith.removeAll()
    }
}
