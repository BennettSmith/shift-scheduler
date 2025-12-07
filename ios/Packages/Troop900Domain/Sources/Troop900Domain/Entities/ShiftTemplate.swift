import Foundation

/// Represents a template for creating shifts with predefined settings.
public struct ShiftTemplate: Identifiable, Equatable, Sendable, Codable {
    public let id: String
    public let name: String
    public let startTime: Date
    public let endTime: Date
    public let requiredScouts: Int
    public let requiredParents: Int
    public let location: String
    public let label: String?
    public let notes: String?
    public let isActive: Bool
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: String,
        name: String,
        startTime: Date,
        endTime: Date,
        requiredScouts: Int,
        requiredParents: Int,
        location: String,
        label: String?,
        notes: String?,
        isActive: Bool,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.requiredScouts = requiredScouts
        self.requiredParents = requiredParents
        self.location = location
        self.label = label
        self.notes = notes
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
