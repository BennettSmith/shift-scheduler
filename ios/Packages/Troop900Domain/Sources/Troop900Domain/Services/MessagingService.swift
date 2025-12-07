import Foundation

/// Protocol for messaging remote operations (Cloud Functions).
public protocol MessagingService: Sendable {
    /// Send a message to users.
    /// - Parameter request: The send message request.
    /// - Returns: The ID of the sent message.
    func sendMessage(request: SendMessageRequest) async throws -> String
    
    /// Send a shift reminder notification.
    /// - Parameter shiftId: The shift's ID.
    func sendShiftReminder(shiftId: String) async throws
    
    /// Send a shift cancellation notification.
    /// - Parameters:
    ///   - shiftId: The shift's ID.
    ///   - reason: The reason for cancellation.
    func sendShiftCancellation(shiftId: String, reason: String?) async throws
}
