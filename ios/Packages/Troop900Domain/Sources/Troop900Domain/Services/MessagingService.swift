import Foundation

/// Protocol for messaging remote operations (Cloud Functions).
public protocol MessagingService: Sendable {
    /// Send a message to users.
    /// - Parameters:
    ///   - title: The message title.
    ///   - body: The message body.
    ///   - targetAudience: The target audience for the message.
    ///   - targetUserIds: Optional list of specific user IDs.
    ///   - targetHouseholdIds: Optional list of specific household IDs.
    ///   - priority: The message priority.
    /// - Returns: The ID of the sent message.
    func sendMessage(
        title: String,
        body: String,
        targetAudience: TargetAudience,
        targetUserIds: [String]?,
        targetHouseholdIds: [String]?,
        priority: MessagePriority
    ) async throws -> String
    
    /// Send a shift reminder notification.
    /// - Parameter shiftId: The shift's ID.
    func sendShiftReminder(shiftId: String) async throws
    
    /// Send a shift cancellation notification.
    /// - Parameters:
    ///   - shiftId: The shift's ID.
    ///   - reason: The reason for cancellation.
    func sendShiftCancellation(shiftId: String, reason: String?) async throws
}
