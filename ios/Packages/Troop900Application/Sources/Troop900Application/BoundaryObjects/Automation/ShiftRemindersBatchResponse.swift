import Foundation
import Troop900Domain

/// Response from batch shift reminder job.
public struct ShiftRemindersBatchResponse: Sendable, Equatable {
    /// Number of shifts processed
    public let shiftsProcessed: Int
    
    /// Number of reminders sent
    public let remindersSent: Int
    
    /// Number of failures
    public let failures: Int
    
    /// Individual reminder results
    public let reminders: [ShiftReminderEntry]
    
    /// When the batch was processed
    public let processedAt: Date
    
    /// Total processing time in seconds
    public let processingTimeSeconds: Double
    
    public init(
        shiftsProcessed: Int,
        remindersSent: Int,
        failures: Int,
        reminders: [ShiftReminderEntry],
        processedAt: Date,
        processingTimeSeconds: Double
    ) {
        self.shiftsProcessed = shiftsProcessed
        self.remindersSent = remindersSent
        self.failures = failures
        self.reminders = reminders
        self.processedAt = processedAt
        self.processingTimeSeconds = processingTimeSeconds
    }
}

/// Individual shift reminder entry.
public struct ShiftReminderEntry: Sendable, Equatable, Identifiable {
    public let id: String
    public let shiftId: String
    public let shiftDate: Date
    public let shiftLabel: String?
    public let recipientCount: Int
    public let success: Bool
    public let errorMessage: String?
    
    public init(
        id: String,
        shiftId: String,
        shiftDate: Date,
        shiftLabel: String?,
        recipientCount: Int,
        success: Bool,
        errorMessage: String?
    ) {
        self.id = id
        self.shiftId = shiftId
        self.shiftDate = shiftDate
        self.shiftLabel = shiftLabel
        self.recipientCount = recipientCount
        self.success = success
        self.errorMessage = errorMessage
    }
}
