import Foundation

/// Represents a scheduled shift at the tree lot.
public struct Shift: Identifiable, Equatable, Sendable, Codable {
    public let id: ShiftId
    public let date: Date
    public let startTime: Date
    public let endTime: Date
    public let requiredScouts: Int
    public let requiredParents: Int
    public let currentScouts: Int
    public let currentParents: Int
    public let location: String
    public let label: String?
    public let notes: String?
    public let status: ShiftStatus
    public let seasonId: String?
    public let templateId: String?
    public let createdAt: Date
    
    public init(
        id: ShiftId,
        date: Date,
        startTime: Date,
        endTime: Date,
        requiredScouts: Int,
        requiredParents: Int,
        currentScouts: Int,
        currentParents: Int,
        location: String,
        label: String?,
        notes: String?,
        status: ShiftStatus,
        seasonId: String?,
        templateId: String?,
        createdAt: Date
    ) {
        self.id = id
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.requiredScouts = requiredScouts
        self.requiredParents = requiredParents
        self.currentScouts = currentScouts
        self.currentParents = currentParents
        self.location = location
        self.label = label
        self.notes = notes
        self.status = status
        self.seasonId = seasonId
        self.templateId = templateId
        self.createdAt = createdAt
    }
    
    public var staffingStatus: StaffingStatus {
        if currentScouts >= requiredScouts && currentParents >= requiredParents {
            return .full
        } else if currentScouts > 0 || currentParents > 0 {
            return .partial
        }
        return .empty
    }
    
    public var needsScouts: Bool {
        currentScouts < requiredScouts
    }
    
    public var needsParents: Bool {
        currentParents < requiredParents
    }
    
    public var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
}
