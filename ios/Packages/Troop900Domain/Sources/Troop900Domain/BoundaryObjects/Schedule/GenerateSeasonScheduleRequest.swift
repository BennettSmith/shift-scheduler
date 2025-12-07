import Foundation

public struct GenerateSeasonScheduleRequest: Sendable, Equatable {
    public let seasonId: String
    public let seasonName: String
    public let startDate: Date
    public let endDate: Date
    public let defaultLocation: String
    public let templateIds: [String]
    public let specialEventDates: [SpecialEventConfig]
    public let excludedDates: [Date]
    
    public init(
        seasonId: String,
        seasonName: String,
        startDate: Date,
        endDate: Date,
        defaultLocation: String,
        templateIds: [String],
        specialEventDates: [SpecialEventConfig] = [],
        excludedDates: [Date] = []
    ) {
        self.seasonId = seasonId
        self.seasonName = seasonName
        self.startDate = startDate
        self.endDate = endDate
        self.defaultLocation = defaultLocation
        self.templateIds = templateIds
        self.specialEventDates = specialEventDates
        self.excludedDates = excludedDates
    }
}

public struct SpecialEventConfig: Sendable, Equatable {
    public let date: Date
    public let templateId: String
    public let label: String
    public let notes: String?
    
    public init(
        date: Date,
        templateId: String,
        label: String,
        notes: String? = nil
    ) {
        self.date = date
        self.templateId = templateId
        self.label = label
        self.notes = notes
    }
}
