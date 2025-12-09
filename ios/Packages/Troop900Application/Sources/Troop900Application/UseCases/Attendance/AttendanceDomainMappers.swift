import Foundation
import Troop900Domain

// MARK: - Domain to Boundary Mappers

extension UserRoleType {
    init(from domain: UserRole) {
        switch domain {
        case .scout: self = .scout
        case .parent: self = .parent
        case .scoutmaster: self = .scoutmaster
        case .assistantScoutmaster: self = .assistantScoutmaster
        }
    }
}

extension ParticipantType {
    init(from domain: AssignmentType) {
        switch domain {
        case .scout: self = .scout
        case .parent: self = .parent
        }
    }
}

extension CheckInMethodType {
    init(from domain: CheckInMethod) {
        switch domain {
        case .qrCode: self = .qrCode
        case .manual: self = .manual
        case .adminOverride: self = .adminOverride
        }
    }
}

extension AttendanceStatusType {
    init(from domain: AttendanceStatus) {
        switch domain {
        case .pending: self = .pending
        case .checkedIn: self = .checkedIn
        case .checkedOut: self = .checkedOut
        case .noShow: self = .noShow
        case .excused: self = .excused
        }
    }
}

extension Coordinate {
    init(from domain: GeoLocation) {
        self.init(latitude: domain.latitude, longitude: domain.longitude)
    }
}

// MARK: - Boundary to Domain Mappers

extension AssignmentType {
    init(from boundary: ParticipantType) {
        switch boundary {
        case .scout: self = .scout
        case .parent: self = .parent
        }
    }
}

extension AttendanceStatus {
    init(from boundary: AttendanceStatusType) {
        switch boundary {
        case .pending: self = .pending
        case .checkedIn: self = .checkedIn
        case .checkedOut: self = .checkedOut
        case .noShow: self = .noShow
        case .excused: self = .excused
        }
    }
}

extension GeoLocation {
    init(from boundary: Coordinate) {
        self.init(latitude: boundary.latitude, longitude: boundary.longitude)
    }
}
