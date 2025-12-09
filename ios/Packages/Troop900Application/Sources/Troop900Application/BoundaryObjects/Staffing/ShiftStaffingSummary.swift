import Foundation

/// Enhanced shift summary with detailed staffing indicators.
public struct ShiftStaffingSummary: Sendable, Equatable, Identifiable {
    public let id: String
    public let date: Date
    public let startTime: Date
    public let endTime: Date
    public let location: String
    public let label: String?
    public let status: ShiftStatusType
    public let timeRange: String
    
    // Scout staffing
    public let requiredScouts: Int
    public let currentScouts: Int
    public let scoutStaffingLevel: StaffingLevelType
    
    // Parent staffing
    public let requiredParents: Int
    public let currentParents: Int
    public let parentStaffingLevel: StaffingLevelType
    
    // Overall staffing
    public let overallStaffingLevel: StaffingLevelType
    public let openSlots: Int
    
    public init(
        id: String,
        date: Date,
        startTime: Date,
        endTime: Date,
        location: String,
        label: String?,
        status: ShiftStatusType,
        timeRange: String,
        requiredScouts: Int,
        currentScouts: Int,
        scoutStaffingLevel: StaffingLevelType,
        requiredParents: Int,
        currentParents: Int,
        parentStaffingLevel: StaffingLevelType,
        overallStaffingLevel: StaffingLevelType,
        openSlots: Int
    ) {
        self.id = id
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.label = label
        self.status = status
        self.timeRange = timeRange
        self.requiredScouts = requiredScouts
        self.currentScouts = currentScouts
        self.scoutStaffingLevel = scoutStaffingLevel
        self.requiredParents = requiredParents
        self.currentParents = currentParents
        self.parentStaffingLevel = parentStaffingLevel
        self.overallStaffingLevel = overallStaffingLevel
        self.openSlots = openSlots
    }
}
