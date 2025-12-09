import Foundation

/// An alert for an understaffed shift.
public struct StaffingAlert: Sendable, Equatable, Identifiable {
    public let id: String
    public let shiftId: String
    public let shiftDate: Date
    public let shiftLabel: String?
    public let timeRange: String
    public let location: String
    
    /// Overall staffing level (critical or low)
    public let staffingLevel: StaffingLevelType
    
    /// Scout staffing details
    public let requiredScouts: Int
    public let currentScouts: Int
    public let scoutShortfall: Int
    
    /// Parent staffing details
    public let requiredParents: Int
    public let currentParents: Int
    public let parentShortfall: Int
    
    /// Total open slots
    public let totalOpenSlots: Int
    
    /// Days until shift
    public let daysUntilShift: Int
    
    public init(
        id: String,
        shiftId: String,
        shiftDate: Date,
        shiftLabel: String?,
        timeRange: String,
        location: String,
        staffingLevel: StaffingLevelType,
        requiredScouts: Int,
        currentScouts: Int,
        scoutShortfall: Int,
        requiredParents: Int,
        currentParents: Int,
        parentShortfall: Int,
        totalOpenSlots: Int,
        daysUntilShift: Int
    ) {
        self.id = id
        self.shiftId = shiftId
        self.shiftDate = shiftDate
        self.shiftLabel = shiftLabel
        self.timeRange = timeRange
        self.location = location
        self.staffingLevel = staffingLevel
        self.requiredScouts = requiredScouts
        self.currentScouts = currentScouts
        self.scoutShortfall = scoutShortfall
        self.requiredParents = requiredParents
        self.currentParents = currentParents
        self.parentShortfall = parentShortfall
        self.totalOpenSlots = totalOpenSlots
        self.daysUntilShift = daysUntilShift
    }
}
