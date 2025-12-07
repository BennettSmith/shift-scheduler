import Foundation

/// Summary information about a shift for list displays.
public struct ShiftSummary: Sendable, Equatable, Identifiable {
    public let id: String
    public let date: Date
    public let startTime: Date
    public let endTime: Date
    public let requiredScouts: Int
    public let requiredParents: Int
    public let currentScouts: Int
    public let currentParents: Int
    public let location: String
    public let label: String?
    public let status: ShiftStatus
    public let staffingStatus: StaffingStatus
    public let timeRange: String
    
    public init(
        id: String,
        date: Date,
        startTime: Date,
        endTime: Date,
        requiredScouts: Int,
        requiredParents: Int,
        currentScouts: Int,
        currentParents: Int,
        location: String,
        label: String?,
        status: ShiftStatus,
        staffingStatus: StaffingStatus,
        timeRange: String
    ) {
        self.id = id
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.requiredScouts = requiredScouts
        self.requiredParents = requiredParents
        self.currentScouts = currentScouts
        self.currentParents = currentParents
        self.location = location
        self.label = label
        self.status = status
        self.staffingStatus = staffingStatus
        self.timeRange = timeRange
    }
}
