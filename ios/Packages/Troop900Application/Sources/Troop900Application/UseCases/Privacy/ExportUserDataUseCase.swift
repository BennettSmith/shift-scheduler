import Foundation
import Troop900Domain

/// Protocol for exporting user data.
public protocol ExportUserDataUseCaseProtocol: Sendable {
    func execute(request: ExportUserDataRequest) async throws -> ExportUserDataResponse
}

/// Use case for exporting all user data (GDPR/CCPA compliance).
/// Used by UC 48 for users to request their data or admins to export on behalf of users.
public final class ExportUserDataUseCase: ExportUserDataUseCaseProtocol, Sendable {
    private let userRepository: UserRepository
    private let assignmentRepository: AssignmentRepository
    private let attendanceRepository: AttendanceRepository
    private let householdRepository: HouseholdRepository
    
    public init(
        userRepository: UserRepository,
        assignmentRepository: AssignmentRepository,
        attendanceRepository: AttendanceRepository,
        householdRepository: HouseholdRepository
    ) {
        self.userRepository = userRepository
        self.assignmentRepository = assignmentRepository
        self.attendanceRepository = attendanceRepository
        self.householdRepository = householdRepository
    }
    
    public func execute(request: ExportUserDataRequest) async throws -> ExportUserDataResponse {
        // Validate and convert boundary IDs to domain ID types
        let userId = try UserId(request.userId)
        let requestingUserId = try UserId(request.requestingUserId)
        
        // Validate requesting user has permission
        let requestingUser = try await userRepository.getUser(id: requestingUserId)
        let isAdmin = requestingUser.role.isLeadership
        let isSelf = request.userId == request.requestingUserId
        
        guard isAdmin || isSelf else {
            throw DomainError.unauthorized
        }
        
        // Get user to export
        let user = try await userRepository.getUser(id: userId)
        
        // Export profile
        let profile = ExportedProfile(
            userId: user.id.value,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            role: user.role.rawValue,
            accountStatus: user.accountStatus.rawValue,
            createdAt: user.createdAt,
            updatedAt: user.updatedAt
        )
        
        // Export households
        var exportedHouseholds: [ExportedHousehold] = []
        for householdId in user.households {
            if let household = try? await householdRepository.getHousehold(id: householdId) {
                let role = user.canManageHouseholds.contains(householdId) ? "manager" : "member"
                exportedHouseholds.append(ExportedHousehold(
                    householdId: household.id,
                    householdName: household.name,
                    role: role,
                    joinedAt: user.createdAt // Would ideally track actual join date
                ))
            }
        }
        
        // Export assignments
        let assignments = try await assignmentRepository.getAssignmentsForUser(userId: userId)
        let exportedAssignments = assignments.map { assignment in
            ExportedAssignment(
                assignmentId: assignment.id.value,
                shiftDate: assignment.assignedAt, // Would ideally get actual shift date
                shiftLabel: nil,
                assignmentType: assignment.assignmentType.rawValue,
                status: assignment.status.rawValue,
                assignedAt: assignment.assignedAt
            )
        }
        
        // Export attendance records
        let attendanceRecords = try await attendanceRepository.getAttendanceRecordsForUser(userId: userId)
        let exportedAttendance = attendanceRecords.map { record in
            ExportedAttendanceRecord(
                recordId: record.id.value,
                shiftDate: record.checkInTime ?? Date(),
                checkInTime: record.checkInTime,
                checkOutTime: record.checkOutTime,
                hoursWorked: record.hoursWorked,
                status: record.status.rawValue
            )
        }
        
        // Export messages (placeholder - would need message repository)
        let exportedMessages: [ExportedMessage] = []
        
        // Export achievements (placeholder)
        let achievements: [String] = []
        
        // Create metadata
        let now = Date()
        let totalRecords = 1 + exportedHouseholds.count + exportedAssignments.count + exportedAttendance.count
        let metadata = ExportMetadata(
            exportedAt: now,
            exportVersion: "1.0",
            totalRecords: totalRecords
        )
        
        // Build complete export
        let userDataExport = UserDataExport(
            profile: profile,
            households: exportedHouseholds,
            assignments: exportedAssignments,
            attendanceRecords: exportedAttendance,
            messages: exportedMessages,
            achievements: achievements,
            metadata: metadata
        )
        
        // Calculate size (rough estimate)
        let encoder = JSONEncoder()
        let data = try encoder.encode(userDataExport)
        let sizeInBytes = data.count
        
        return ExportUserDataResponse(
            userDataExport: userDataExport,
            downloadUrl: nil, // Would generate URL for large exports
            sizeInBytes: sizeInBytes,
            generatedAt: now
        )
    }
}
