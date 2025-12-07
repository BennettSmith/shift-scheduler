import Foundation

/// Represents a family unit within a household (e.g., parent + scout(s)).
public struct FamilyUnit: Identifiable, Equatable, Sendable, Codable {
    public let id: String
    public let householdId: String
    public let scouts: [String] // User IDs
    public let parents: [String] // User IDs
    public let name: String?
    public let createdAt: Date
    
    public init(
        id: String,
        householdId: String,
        scouts: [String],
        parents: [String],
        name: String?,
        createdAt: Date
    ) {
        self.id = id
        self.householdId = householdId
        self.scouts = scouts
        self.parents = parents
        self.name = name
        self.createdAt = createdAt
    }
    
    public var allMembers: [String] {
        scouts + parents
    }
}
