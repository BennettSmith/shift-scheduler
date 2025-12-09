import Foundation

/// Response containing comprehensive season-wide statistics for committee.
public struct SeasonStatisticsResponse: Sendable, Equatable {
    /// Season identifier
    public let seasonId: String
    
    /// Season name or label
    public let seasonName: String
    
    /// Season start and end dates
    public let startDate: Date
    public let endDate: Date
    
    /// Overall participation statistics
    public let participation: ParticipationStats
    
    /// Shift statistics
    public let shifts: ShiftStats
    
    /// Volunteer hour statistics
    public let hours: HourStats
    
    /// Top performers
    public let topVolunteers: [TopVolunteerEntry]
    
    /// Top families (by combined hours)
    public let topFamilies: [TopFamilyEntry]
    
    /// Attendance and reliability metrics
    public let attendance: AttendanceStats
    
    public init(
        seasonId: String,
        seasonName: String,
        startDate: Date,
        endDate: Date,
        participation: ParticipationStats,
        shifts: ShiftStats,
        hours: HourStats,
        topVolunteers: [TopVolunteerEntry],
        topFamilies: [TopFamilyEntry],
        attendance: AttendanceStats
    ) {
        self.seasonId = seasonId
        self.seasonName = seasonName
        self.startDate = startDate
        self.endDate = endDate
        self.participation = participation
        self.shifts = shifts
        self.hours = hours
        self.topVolunteers = topVolunteers
        self.topFamilies = topFamilies
        self.attendance = attendance
    }
}

/// Participation statistics.
public struct ParticipationStats: Sendable, Equatable {
    public let totalFamilies: Int
    public let activeFamilies: Int
    public let totalVolunteers: Int
    public let activeVolunteers: Int
    public let totalScouts: Int
    public let totalParents: Int
    
    public init(
        totalFamilies: Int,
        activeFamilies: Int,
        totalVolunteers: Int,
        activeVolunteers: Int,
        totalScouts: Int,
        totalParents: Int
    ) {
        self.totalFamilies = totalFamilies
        self.activeFamilies = activeFamilies
        self.totalVolunteers = totalVolunteers
        self.activeVolunteers = activeVolunteers
        self.totalScouts = totalScouts
        self.totalParents = totalParents
    }
}

/// Shift statistics.
public struct ShiftStats: Sendable, Equatable {
    public let totalShifts: Int
    public let completedShifts: Int
    public let totalSlots: Int
    public let filledSlots: Int
    public let averageStaffingRate: Double // Percentage
    
    public init(
        totalShifts: Int,
        completedShifts: Int,
        totalSlots: Int,
        filledSlots: Int,
        averageStaffingRate: Double
    ) {
        self.totalShifts = totalShifts
        self.completedShifts = completedShifts
        self.totalSlots = totalSlots
        self.filledSlots = filledSlots
        self.averageStaffingRate = averageStaffingRate
    }
}

/// Hour statistics.
public struct HourStats: Sendable, Equatable {
    public let totalHours: Double
    public let scoutHours: Double
    public let parentHours: Double
    public let averageHoursPerVolunteer: Double
    public let averageHoursPerFamily: Double
    
    public init(
        totalHours: Double,
        scoutHours: Double,
        parentHours: Double,
        averageHoursPerVolunteer: Double,
        averageHoursPerFamily: Double
    ) {
        self.totalHours = totalHours
        self.scoutHours = scoutHours
        self.parentHours = parentHours
        self.averageHoursPerVolunteer = averageHoursPerVolunteer
        self.averageHoursPerFamily = averageHoursPerFamily
    }
}

/// Attendance statistics.
public struct AttendanceStats: Sendable, Equatable {
    public let totalAssignments: Int
    public let completedAssignments: Int
    public let noShows: Int
    public let completionRate: Double // Percentage
    
    public init(
        totalAssignments: Int,
        completedAssignments: Int,
        noShows: Int,
        completionRate: Double
    ) {
        self.totalAssignments = totalAssignments
        self.completedAssignments = completedAssignments
        self.noShows = noShows
        self.completionRate = completionRate
    }
}

/// Top volunteer entry.
public struct TopVolunteerEntry: Sendable, Equatable, Identifiable {
    public let id: String // User ID
    public let name: String
    public let role: UserRoleType
    public let totalHours: Double
    public let totalShifts: Int
    public let rank: Int
    
    public init(
        id: String,
        name: String,
        role: UserRoleType,
        totalHours: Double,
        totalShifts: Int,
        rank: Int
    ) {
        self.id = id
        self.name = name
        self.role = role
        self.totalHours = totalHours
        self.totalShifts = totalShifts
        self.rank = rank
    }
}

/// Top family entry.
public struct TopFamilyEntry: Sendable, Equatable, Identifiable {
    public let id: String // Household ID
    public let familyName: String
    public let totalHours: Double
    public let totalShifts: Int
    public let memberCount: Int
    public let rank: Int
    
    public init(
        id: String,
        familyName: String,
        totalHours: Double,
        totalShifts: Int,
        memberCount: Int,
        rank: Int
    ) {
        self.id = id
        self.familyName = familyName
        self.totalHours = totalHours
        self.totalShifts = totalShifts
        self.memberCount = memberCount
        self.rank = rank
    }
}
