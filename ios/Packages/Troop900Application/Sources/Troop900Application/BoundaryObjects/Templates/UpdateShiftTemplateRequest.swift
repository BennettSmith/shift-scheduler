import Foundation
import Troop900Domain

public struct UpdateShiftTemplateRequest: Sendable, Equatable {
    public let templateId: String
    public let name: String?
    public let startTime: Date?
    public let endTime: Date?
    public let requiredScouts: Int?
    public let requiredParents: Int?
    public let location: String?
    public let label: String?
    public let notes: String?
    public let isActive: Bool?
    
    public init(
        templateId: String,
        name: String? = nil,
        startTime: Date? = nil,
        endTime: Date? = nil,
        requiredScouts: Int? = nil,
        requiredParents: Int? = nil,
        location: String? = nil,
        label: String? = nil,
        notes: String? = nil,
        isActive: Bool? = nil
    ) {
        self.templateId = templateId
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.requiredScouts = requiredScouts
        self.requiredParents = requiredParents
        self.location = location
        self.label = label
        self.notes = notes
        self.isActive = isActive
    }
}
