import Foundation
import Testing
@testable import Troop900Domain

@Suite("Message Tests")
struct MessageTests {
    
    @Test("Message initialization")
    func messageInitialization() {
        let message = Message(
            id: "message-1",
            title: "Shift Reminder",
            body: "Don't forget your shift tomorrow!",
            targetAudience: .scouts,
            targetUserIds: ["user-1", "user-2"],
            targetHouseholdIds: nil,
            senderId: "admin-1",
            sentAt: Date(),
            priority: .high,
            isRead: false
        )
        
        #expect(message.id == "message-1")
        #expect(message.title == "Shift Reminder")
        #expect(message.body == "Don't forget your shift tomorrow!")
        #expect(message.targetAudience == .scouts)
        #expect(message.priority == .high)
        #expect(!message.isRead)
    }
}

@Suite("MessagePriority Tests")
struct MessagePriorityTests {
    
    @Test("Message priority display names")
    func messagePriorityDisplayNames() {
        #expect(MessagePriority.low.displayName == "Low")
        #expect(MessagePriority.normal.displayName == "Normal")
        #expect(MessagePriority.high.displayName == "High")
        #expect(MessagePriority.urgent.displayName == "Urgent")
    }
    
    @Test("Message priority raw values")
    func messagePriorityRawValues() {
        #expect(MessagePriority.low.rawValue == "low")
        #expect(MessagePriority.normal.rawValue == "normal")
        #expect(MessagePriority.high.rawValue == "high")
        #expect(MessagePriority.urgent.rawValue == "urgent")
    }
}
