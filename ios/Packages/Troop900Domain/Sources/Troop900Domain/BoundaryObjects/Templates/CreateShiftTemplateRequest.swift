import Foundation

public struct CreateShiftTemplateRequest: Sendable, Equatable {
    public let name: String
    public let startTime: Date
    public let endTime: Date
    public let requiredScouts: Int
    public let requiredParents: Int
    public let location: String
    public let label: String?
    public let notes: String?
    
    public init(
        name: String,
        startTime: Date,
        endTime: Date,
        requiredScouts: Int,
        requiredParents: Int,
        location: String,
        label: String? = nil,
        notes: String? = nil
    ) {
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.requiredScouts = requiredScouts
        self.requiredParents = requiredParents
        self.location = location
        self.label = label
        self.notes = notes
    }
}
