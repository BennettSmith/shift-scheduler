import Foundation

/// Represents a tree lot season (typically a year).
public struct Season: Identifiable, Equatable, Sendable, Codable {
    public let id: String
    public let name: String
    public let year: Int
    public let startDate: Date
    public let endDate: Date
    public let status: SeasonStatus
    public let description: String?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: String,
        name: String,
        year: Int,
        startDate: Date,
        endDate: Date,
        status: SeasonStatus,
        description: String?,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.name = name
        self.year = year
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.description = description
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    public var isActive: Bool {
        status.isActive
    }
}
