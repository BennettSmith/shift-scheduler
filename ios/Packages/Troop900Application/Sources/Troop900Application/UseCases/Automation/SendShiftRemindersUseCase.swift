import Foundation
import Troop900Domain

/// Protocol for sending shift reminders.
public protocol SendShiftRemindersUseCaseProtocol: Sendable {
    func execute() async throws -> ShiftRemindersBatchResponse
}

/// Use case for sending automated shift reminders 24 hours before shifts.
/// Used by UC 6 for background job to remind volunteers about upcoming shifts.
/// This would typically be triggered by a scheduler (cron job, cloud function timer, etc.).
public final class SendShiftRemindersUseCase: SendShiftRemindersUseCaseProtocol, Sendable {
    private let shiftRepository: ShiftRepository
    private let assignmentRepository: AssignmentRepository
    private let userRepository: UserRepository
    
    public init(
        shiftRepository: ShiftRepository,
        assignmentRepository: AssignmentRepository,
        userRepository: UserRepository
    ) {
        self.shiftRepository = shiftRepository
        self.assignmentRepository = assignmentRepository
        self.userRepository = userRepository
    }
    
    public func execute() async throws -> ShiftRemindersBatchResponse {
        let startTime = Date()
        
        // Calculate time range for shifts starting in 24 hours (±1 hour window)
        let calendar = Calendar.current
        let now = Date()
        let tomorrow = calendar.date(byAdding: .hour, value: 24, to: now)!
        let windowStart = calendar.date(byAdding: .minute, value: -30, to: tomorrow)!
        let windowEnd = calendar.date(byAdding: .minute, value: 30, to: tomorrow)!
        
        // Get all shifts in the 24-hour window
        let shifts = try await shiftRepository.getShiftsForDateRange(start: windowStart, end: windowEnd)
        
        // Filter to only published shifts
        let publishedShifts = shifts.filter { $0.status == .published }
        
        var reminderEntries: [ShiftReminderEntry] = []
        var totalRemindersSent = 0
        var totalFailures = 0
        
        for shift in publishedShifts {
            // Get all active assignments for this shift
            let assignments = try await assignmentRepository.getAssignmentsForShift(shiftId: shift.id)
            let activeAssignments = assignments.filter { $0.isActive }
            
            guard !activeAssignments.isEmpty else {
                continue // Skip shifts with no assignments
            }
            
            // Get unique user IDs (in case same user has multiple assignments)
            let userIds = Set(activeAssignments.map { $0.userId })
            var successfulNotifications = 0
            var failedNotifications = 0
            
            for userId in userIds {
                do {
                    _ = try await userRepository.getUser(id: userId)
                    
                    // In a real implementation, this would:
                    // 1. Send push notification via notification service
                    // 2. Send email via email service
                    // 3. Send SMS via SMS service (optional)
                    
                    // For now, we'll simulate successful notification
                    // let notificationService.send(user, shift)
                    
                    successfulNotifications += 1
                } catch {
                    failedNotifications += 1
                }
            }
            
            let success = failedNotifications == 0
            totalRemindersSent += successfulNotifications
            totalFailures += failedNotifications
            
            reminderEntries.append(ShiftReminderEntry(
                id: shift.id.value,
                shiftId: shift.id.value,
                shiftDate: shift.date,
                shiftLabel: shift.label,
                recipientCount: userIds.count,
                success: success,
                errorMessage: failedNotifications > 0 ? "Failed to send to \(failedNotifications) recipient(s)" : nil
            ))
        }
        
        let endTime = Date()
        let processingTime = endTime.timeIntervalSince(startTime)
        
        return ShiftRemindersBatchResponse(
            shiftsProcessed: publishedShifts.count,
            remindersSent: totalRemindersSent,
            failures: totalFailures,
            reminders: reminderEntries,
            processedAt: endTime,
            processingTimeSeconds: processingTime
        )
    }
}
