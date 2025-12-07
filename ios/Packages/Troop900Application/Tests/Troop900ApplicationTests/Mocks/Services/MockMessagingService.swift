import Foundation
import Troop900Domain

/// Mock implementation of MessagingService for testing
public final class MockMessagingService: MessagingService, @unchecked Sendable {
    
    // MARK: - Configurable Results
    
    public var sendMessageResult: Result<String, Error>?
    public var sendShiftReminderError: Error?
    public var sendShiftCancellationError: Error?
    
    // MARK: - Call Tracking
    
    public var sendMessageCallCount = 0
    public var sendMessageCalledWith: [(title: String, body: String, targetAudience: TargetAudience, targetUserIds: [String]?, targetHouseholdIds: [String]?, priority: MessagePriority)] = []
    
    public var sendShiftReminderCallCount = 0
    public var sendShiftReminderCalledWith: [String] = []
    
    public var sendShiftCancellationCallCount = 0
    public var sendShiftCancellationCalledWith: [(shiftId: String, reason: String?)] = []
    
    // MARK: - MessagingService Implementation
    
    public func sendMessage(
        title: String,
        body: String,
        targetAudience: TargetAudience,
        targetUserIds: [String]?,
        targetHouseholdIds: [String]?,
        priority: MessagePriority
    ) async throws -> String {
        sendMessageCallCount += 1
        sendMessageCalledWith.append((title, body, targetAudience, targetUserIds, targetHouseholdIds, priority))
        
        if let result = sendMessageResult {
            return try result.get()
        }
        
        // Return a generated message ID
        return "message-\(UUID().uuidString.prefix(8))"
    }
    
    public func sendShiftReminder(shiftId: String) async throws {
        sendShiftReminderCallCount += 1
        sendShiftReminderCalledWith.append(shiftId)
        
        if let error = sendShiftReminderError {
            throw error
        }
    }
    
    public func sendShiftCancellation(shiftId: String, reason: String?) async throws {
        sendShiftCancellationCallCount += 1
        sendShiftCancellationCalledWith.append((shiftId, reason))
        
        if let error = sendShiftCancellationError {
            throw error
        }
    }
    
    // MARK: - Test Helpers
    
    /// Resets all state and call tracking
    public func reset() {
        sendMessageResult = nil
        sendShiftReminderError = nil
        sendShiftCancellationError = nil
        sendMessageCallCount = 0
        sendMessageCalledWith.removeAll()
        sendShiftReminderCallCount = 0
        sendShiftReminderCalledWith.removeAll()
        sendShiftCancellationCallCount = 0
        sendShiftCancellationCalledWith.removeAll()
    }
}
