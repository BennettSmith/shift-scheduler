import Foundation

/// Represents a household containing multiple family units.
public struct Household: Identifiable, Equatable, Sendable, Codable {
    public let id: String
    public let name: String
    public let members: [String] // User IDs
    public let managers: [String] // User IDs who can manage this household
    public let familyUnits: [String] // FamilyUnit IDs
    public let linkCode: String?
    public let isActive: Bool
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: String,
        name: String,
        members: [String],
        managers: [String],
        familyUnits: [String],
        linkCode: String?,
        isActive: Bool,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.name = name
        self.members = members
        self.managers = managers
        self.familyUnits = familyUnits
        self.linkCode = linkCode
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
