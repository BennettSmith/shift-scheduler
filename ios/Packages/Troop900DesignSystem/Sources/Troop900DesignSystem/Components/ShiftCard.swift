import SwiftUI

// MARK: - Design System Shift Cards
// Based on Troop 900 iOS UI Design Specification

/// A card displaying shift information.
public struct DSShiftCard: View {
    private let time: String
    private let name: String
    private let scoutCount: Int
    private let scoutRequired: Int
    private let parentCount: Int
    private let parentRequired: Int
    private let isSignedUp: Bool
    private let action: () -> Void
    
    public init(
        time: String,
        name: String,
        scoutCount: Int,
        scoutRequired: Int,
        parentCount: Int,
        parentRequired: Int,
        isSignedUp: Bool = false,
        action: @escaping () -> Void
    ) {
        self.time = time
        self.name = name
        self.scoutCount = scoutCount
        self.scoutRequired = scoutRequired
        self.parentCount = parentCount
        self.parentRequired = parentRequired
        self.isSignedUp = isSignedUp
        self.action = action
    }
    
    private var staffingStatus: DSStaffingBadge.StaffingStatus {
        let scoutsFilled = scoutCount >= scoutRequired
        let parentsFilled = parentCount >= parentRequired
        let totalFilled = scoutCount + parentCount
        let totalRequired = scoutRequired + parentRequired
        let fillRate = Double(totalFilled) / Double(totalRequired)
        
        if scoutsFilled && parentsFilled {
            return .fullyStaffed
        } else if fillRate < 0.5 {
            return .critical
        } else if !scoutsFilled && parentsFilled {
            return .needsHelp("Needs scouts")
        } else if scoutsFilled && !parentsFilled {
            return .needsHelp("Needs parents")
        } else {
            return .needsHelp("Needs help")
        }
    }
    
    public var body: some View {
        Button(action: action) {
            DSCard {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    HStack {
                        Text(time)
                            .font(DSTypography.headline)
                            .foregroundColor(DSColors.textPrimary)
                        
                        Spacer()
                        
                        if isSignedUp {
                            DSIconView(.starred, size: .medium, color: DSColors.primary)
                        }
                    }
                    
                    Text(name)
                        .font(DSTypography.callout)
                        .foregroundColor(DSColors.textSecondary)
                    
                    HStack(spacing: DSSpacing.md) {
                        DSStaffingCountBadge(type: .scout, current: scoutCount, required: scoutRequired)
                        DSStaffingCountBadge(type: .parent, current: parentCount, required: parentRequired)
                        
                        Spacer()
                        
                        DSStaffingBadge(staffingStatus)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Family Shift Card (for Home tab)

/// A card showing a family member's shift assignment.
public struct DSFamilyShiftCard: View {
    public enum PersonType {
        case scout
        case parent
        
        var icon: DSIcon {
            switch self {
            case .scout: return .scout
            case .parent: return .profileFill
            }
        }
    }
    
    private let name: String
    private let personType: PersonType
    private let time: String
    private let shiftName: String
    private let checkInStatus: DSCheckInStatusBadge.Status
    private let attribution: String?
    private let action: (() -> Void)?
    
    public init(
        name: String,
        personType: PersonType,
        time: String,
        shiftName: String,
        checkInStatus: DSCheckInStatusBadge.Status,
        attribution: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.name = name
        self.personType = personType
        self.time = time
        self.shiftName = shiftName
        self.checkInStatus = checkInStatus
        self.attribution = attribution
        self.action = action
    }
    
    public var body: some View {
        let content = HStack(spacing: DSSpacing.md) {
            DSIconView(personType.icon, size: .large, color: DSColors.primary)
            
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                HStack {
                    Text(name)
                        .font(DSTypography.headline)
                        .foregroundColor(DSColors.textPrimary)
                    
                    Spacer()
                    
                    Text(time)
                        .font(DSTypography.subhead)
                        .foregroundColor(DSColors.textSecondary)
                }
                
                Text(shiftName)
                    .font(DSTypography.callout)
                    .foregroundColor(DSColors.textSecondary)
                
                HStack {
                    DSCheckInStatusBadge(checkInStatus)
                    
                    if let attribution = attribution {
                        Spacer()
                        Text("Signed up by: \(attribution)")
                            .font(DSTypography.caption2)
                            .foregroundColor(DSColors.textTertiary)
                    }
                }
            }
        }
        .padding(DSSpacing.md)
        .background(DSColors.backgroundElevated)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
        
        if let action = action {
            Button(action: action) {
                content
            }
            .buttonStyle(.plain)
        } else {
            content
        }
    }
}

// MARK: - Week Card (for Schedule tab)

/// A card showing a week overview.
public struct DSWeekCard: View {
    private let weekNumber: Int
    private let dateRange: String
    private let totalShifts: Int
    private let needsCoverage: Int
    private let signedUp: Int
    private let action: () -> Void
    
    public init(
        weekNumber: Int,
        dateRange: String,
        totalShifts: Int,
        needsCoverage: Int,
        signedUp: Int,
        action: @escaping () -> Void
    ) {
        self.weekNumber = weekNumber
        self.dateRange = dateRange
        self.totalShifts = totalShifts
        self.needsCoverage = needsCoverage
        self.signedUp = signedUp
        self.action = action
    }
    
    private var coverageStatus: (icon: DSIcon, text: String, color: Color) {
        if needsCoverage == 0 {
            return (.success, "Fully staffed", DSColors.success)
        } else if needsCoverage >= 3 {
            return (.critical, "\(needsCoverage) need coverage", DSColors.error)
        } else {
            return (.warning, "\(needsCoverage) need coverage", DSColors.warning)
        }
    }
    
    public var body: some View {
        Button(action: action) {
            DSCard {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Text("Week \(weekNumber)")
                        .font(DSTypography.title3)
                        .foregroundColor(DSColors.textPrimary)
                    
                    Text(dateRange)
                        .font(DSTypography.callout)
                        .foregroundColor(DSColors.textSecondary)
                    
                    HStack(spacing: DSSpacing.md) {
                        HStack(spacing: DSSpacing.xs) {
                            DSIconView(.calendar, size: .small, color: DSColors.textTertiary)
                            Text("\(totalShifts) shifts")
                                .font(DSTypography.caption1)
                                .foregroundColor(DSColors.textSecondary)
                        }
                        
                        HStack(spacing: DSSpacing.xs) {
                            DSIconView(coverageStatus.icon, size: .small, color: coverageStatus.color)
                            Text(coverageStatus.text)
                                .font(DSTypography.caption1)
                                .foregroundColor(coverageStatus.color)
                        }
                        
                        HStack(spacing: DSSpacing.xs) {
                            DSIconView(.starred, size: .small, color: DSColors.primary)
                            Text("\(signedUp) signed up")
                                .font(DSTypography.caption1)
                                .foregroundColor(DSColors.textSecondary)
                        }
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Shift Info Header

/// A header showing shift details (used in Shift Detail screen).
public struct DSShiftInfoHeader: View {
    private let name: String
    private let date: String
    private let time: String
    private let location: String?
    
    public init(
        name: String,
        date: String,
        time: String,
        location: String? = nil
    ) {
        self.name = name
        self.date = date
        self.time = time
        self.location = location
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(name)
                .font(DSTypography.title1)
                .foregroundColor(DSColors.textPrimary)
            
            Text(date)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textSecondary)
            
            Text(time)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textSecondary)
            
            if let location = location {
                HStack(spacing: DSSpacing.xs) {
                    DSIconView(.location, size: .small, color: DSColors.textTertiary)
                    Text(location)
                        .font(DSTypography.body)
                        .foregroundColor(DSColors.textSecondary)
                }
            }
        }
    }
}

// MARK: - Current Shift Card (for Check-In tab)

/// A card showing the current or next shift info.
public struct DSCurrentShiftCard: View {
    public enum ShiftState {
        case current(startedMinutesAgo: Int)
        case upcoming(startsIn: String)
        
        var label: String {
            switch self {
            case .current: return "CURRENT SHIFT"
            case .upcoming: return "NEXT SHIFT"
            }
        }
        
        var statusText: String {
            switch self {
            case .current(let minutes):
                return "In progress • Started \(minutes) min ago"
            case .upcoming(let time):
                return "Starts in \(time)"
            }
        }
        
        var statusColor: Color {
            switch self {
            case .current: return DSColors.success
            case .upcoming: return DSColors.textTertiary
            }
        }
    }
    
    private let name: String
    private let time: String
    private let state: ShiftState
    
    public init(name: String, time: String, state: ShiftState) {
        self.name = name
        self.time = time
        self.state = state
    }
    
    public var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text(state.label)
                    .font(DSTypography.caption1)
                    .foregroundColor(DSColors.textTertiary)
                    .tracking(0.5)
                
                Text(name)
                    .font(DSTypography.title2)
                    .foregroundColor(DSColors.textPrimary)
                
                Text(time)
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textSecondary)
                
                Text(state.statusText)
                    .font(DSTypography.caption1)
                    .foregroundColor(state.statusColor)
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
struct DSShiftCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: DSSpacing.lg) {
                Group {
                    Text("Shift Cards").dsHeadline()
                    
                    DSShiftCard(
                        time: "4:00 PM - 7:00 PM",
                        name: "Weekday Evening",
                        scoutCount: 1,
                        scoutRequired: 2,
                        parentCount: 1,
                        parentRequired: 2
                    ) { }
                    
                    DSShiftCard(
                        time: "9:00 AM - 1:00 PM",
                        name: "Saturday Morning",
                        scoutCount: 3,
                        scoutRequired: 3,
                        parentCount: 2,
                        parentRequired: 2,
                        isSignedUp: true
                    ) { }
                }
                
                Divider()
                
                Group {
                    Text("Family Shift Cards").dsHeadline()
                    
                    DSFamilyShiftCard(
                        name: "Alex Smith",
                        personType: .scout,
                        time: "10:00 AM - 2:00 PM",
                        shiftName: "Morning Shift",
                        checkInStatus: .checkedIn(time: "9:58 AM")
                    )
                    
                    DSFamilyShiftCard(
                        name: "Sarah Smith",
                        personType: .parent,
                        time: "2:00 PM - 6:00 PM",
                        shiftName: "Afternoon Shift",
                        checkInStatus: .notCheckedIn,
                        attribution: "Smith Household"
                    )
                }
                
                Divider()
                
                Group {
                    Text("Week Cards").dsHeadline()
                    
                    DSWeekCard(
                        weekNumber: 1,
                        dateRange: "Nov 25 - Dec 1",
                        totalShifts: 12,
                        needsCoverage: 3,
                        signedUp: 2
                    ) { }
                    
                    DSWeekCard(
                        weekNumber: 2,
                        dateRange: "Dec 2 - Dec 8",
                        totalShifts: 14,
                        needsCoverage: 0,
                        signedUp: 1
                    ) { }
                }
                
                Divider()
                
                Group {
                    Text("Current Shift Cards").dsHeadline()
                    
                    DSCurrentShiftCard(
                        name: "Saturday Morning",
                        time: "9:00 AM - 1:00 PM",
                        state: .current(startedMinutesAgo: 47)
                    )
                    
                    DSCurrentShiftCard(
                        name: "Saturday Afternoon",
                        time: "2:00 PM - 6:00 PM",
                        state: .upcoming(startsIn: "2 hours 15 min")
                    )
                }
            }
            .padding()
        }
        .background(DSColors.neutral100)
    }
}
#endif
