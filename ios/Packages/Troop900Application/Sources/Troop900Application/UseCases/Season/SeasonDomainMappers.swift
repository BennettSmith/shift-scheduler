import Foundation
import Troop900Domain

// MARK: - SeasonStatusType Mapping

extension SeasonStatusType {
    /// Convert from domain SeasonStatus to boundary SeasonStatusType
    init(from domain: SeasonStatus) {
        switch domain {
        case .draft:
            self = .draft
        case .active:
            self = .active
        case .completed:
            self = .completed
        case .archived:
            self = .archived
        }
    }
}

// MARK: - SeasonSummary Mapping

extension SeasonSummary {
    /// Convert from domain Season to boundary SeasonSummary
    init(from season: Season) {
        self.init(
            id: season.id,
            name: season.name,
            year: season.year,
            startDate: season.startDate,
            endDate: season.endDate,
            status: SeasonStatusType(from: season.status),
            description: season.description,
            isActive: season.status == .active
        )
    }
}
