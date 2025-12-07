import Foundation

/// Protocol for getting attendance history.
public protocol GetAttendanceHistoryUseCaseProtocol: Sendable {
    func execute(userId: String) async throws -> AttendanceHistoryResponse
}

/// Use case for retrieving a user's attendance history.
public final class GetAttendanceHistoryUseCase: GetAttendanceHistoryUseCaseProtocol, Sendable {
    private let attendanceRepository: AttendanceRepository
    private let shiftRepository: ShiftRepository
    
    public init(attendanceRepository: AttendanceRepository, shiftRepository: ShiftRepository) {
        self.attendanceRepository = attendanceRepository
        self.shiftRepository = shiftRepository
    }
    
    public func execute(userId: String) async throws -> AttendanceHistoryResponse {
        let records = try await attendanceRepository.getAttendanceRecordsForUser(userId: userId)
        
        var summaries: [AttendanceRecordSummary] = []
        var totalHours: Double = 0
        var completedShifts = 0
        
        for record in records {
            if let shift = try? await shiftRepository.getShift(id: record.shiftId) {
                summaries.append(AttendanceRecordSummary(
                    id: record.id,
                    shiftDate: shift.date,
                    shiftLabel: shift.label,
                    checkInTime: record.checkInTime,
                    checkOutTime: record.checkOutTime,
                    hoursWorked: record.hoursWorked,
                    status: record.status
                ))
                
                if let hours = record.hoursWorked {
                    totalHours += hours
                }
                
                if record.isComplete {
                    completedShifts += 1
                }
            }
        }
        
        // Sort by date descending (most recent first)
        summaries.sort { $0.shiftDate > $1.shiftDate }
        
        return AttendanceHistoryResponse(
            records: summaries,
            totalHours: totalHours,
            completedShifts: completedShifts
        )
    }
}
