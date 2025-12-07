import SwiftUI

// MARK: - Design System Status Badges
// Based on Troop 900 iOS UI Design Specification

/// Status types for badges throughout the app.
public enum DSStatusType {
    /// Fully staffed, confirmed, checked in
    case success
    /// Needs attention, understaffed, warning
    case warning
    /// Critical, error, severely understaffed
    case critical
    /// User is signed up
    case signedUp
    /// Informational
    case info
    /// Neutral/default
    case neutral
    
    var backgroundColor: Color {
        switch self {
        case .success: return DSColors.successLight
        case .warning: return DSColors.warningLight
        case .critical: return DSColors.errorLight
        case .signedUp: return DSColors.primaryLight
        case .info: return DSColors.infoLight
        case .neutral: return DSColors.neutral200
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .success: return DSColors.success
        case .warning: return DSColors.warning
        case .critical: return DSColors.error
        case .signedUp: return DSColors.primary
        case .info: return DSColors.info
        case .neutral: return DSColors.textSecondary
        }
    }
    
    var icon: DSIcon? {
        switch self {
        case .success: return .success
        case .warning: return .warning
        case .critical: return .critical
        case .signedUp: return .starred
        case .info: return .infoFill
        case .neutral: return nil
        }
    }
}

// MARK: - Status Badge

/// A small pill-shaped status indicator.
/// Use for staffing status, check-in status, etc.
public struct DSStatusBadge: View {
    private let text: String
    private let status: DSStatusType
    private let showIcon: Bool
    
    public init(_ text: String, status: DSStatusType, showIcon: Bool = true) {
        self.text = text
        self.status = status
        self.showIcon = showIcon
    }
    
    public var body: some View {
        HStack(spacing: DSSpacing.xs) {
            if showIcon, let icon = status.icon {
                DSIconView(icon, size: .small, color: status.foregroundColor)
            }
            
            Text(text)
                .font(DSTypography.caption2)
                .foregroundColor(status.foregroundColor)
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xs)
        .background(status.backgroundColor)
        .clipShape(Capsule())
    }
}

// MARK: - Staffing Status Badge

/// Specialized badge for shift staffing status.
public struct DSStaffingBadge: View {
    public enum StaffingStatus {
        case fullyStaffed
        case needsHelp(String)  // e.g., "Needs help", "Needs scouts", "Needs parents"
        case critical
        
        var text: String {
            switch self {
            case .fullyStaffed: return "Fully staffed"
            case .needsHelp(let detail): return detail
            case .critical: return "Critical"
            }
        }
        
        var status: DSStatusType {
            switch self {
            case .fullyStaffed: return .success
            case .needsHelp: return .warning
            case .critical: return .critical
            }
        }
    }
    
    private let staffingStatus: StaffingStatus
    
    public init(_ staffingStatus: StaffingStatus) {
        self.staffingStatus = staffingStatus
    }
    
    public var body: some View {
        DSStatusBadge(staffingStatus.text, status: staffingStatus.status)
    }
}

// MARK: - Role Badge

/// Badge showing a user's role (Parent, Scout, Admin, etc.)
public struct DSRoleBadge: View {
    public enum Role: String {
        case parent = "Parent"
        case scout = "Scout"
        case admin = "Admin"
        case committee = "Committee"
        case primary = "Primary"
        case spouse = "Spouse"
        case claimed = "Claimed"
        case unclaimed = "Unclaimed"
    }
    
    private let role: Role
    
    public init(_ role: Role) {
        self.role = role
    }
    
    public var body: some View {
        Text(role.rawValue)
            .font(DSTypography.caption2)
            .foregroundColor(DSColors.textSecondary)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xs)
            .background(DSColors.neutral200)
            .clipShape(Capsule())
    }
}

// MARK: - Check-In Status Badge

/// Badge showing check-in/out status with time.
public struct DSCheckInStatusBadge: View {
    public enum Status {
        case notCheckedIn
        case checkedIn(time: String)
        case checkedOut(time: String)
        case noShow
        
        var text: String {
            switch self {
            case .notCheckedIn: return "Not checked in"
            case .checkedIn(let time): return "✓ Checked in \(time)"
            case .checkedOut(let time): return "✓ Checked out \(time)"
            case .noShow: return "No show"
            }
        }
        
        var color: Color {
            switch self {
            case .notCheckedIn: return DSColors.textTertiary
            case .checkedIn: return DSColors.success
            case .checkedOut: return DSColors.textTertiary
            case .noShow: return DSColors.error
            }
        }
    }
    
    private let status: Status
    
    public init(_ status: Status) {
        self.status = status
    }
    
    public var body: some View {
        Text(status.text)
            .font(DSTypography.caption1)
            .foregroundColor(status.color)
    }
}

// MARK: - Staffing Count Badge

/// Shows current/required counts for scouts or parents.
public struct DSStaffingCountBadge: View {
    public enum PersonType {
        case scout
        case parent
        
        var icon: DSIcon {
            switch self {
            case .scout: return .scout
            case .parent: return .people
            }
        }
        
        var label: String {
            switch self {
            case .scout: return "scouts"
            case .parent: return "parents"
            }
        }
    }
    
    private let type: PersonType
    private let current: Int
    private let required: Int
    
    public init(type: PersonType, current: Int, required: Int) {
        self.type = type
        self.current = current
        self.required = required
    }
    
    private var isFull: Bool {
        current >= required
    }
    
    public var body: some View {
        HStack(spacing: DSSpacing.xs) {
            DSIconView(type.icon, size: .small, color: isFull ? DSColors.success : DSColors.textSecondary)
            
            Text("\(current)/\(required) \(type.label)")
                .font(DSTypography.caption1)
                .foregroundColor(isFull ? DSColors.success : DSColors.textSecondary)
        }
    }
}

// MARK: - Leaderboard Rank Badge

/// Badge showing rank in leaderboard (with medals for top 3).
public struct DSRankBadge: View {
    private let rank: Int
    private let isCurrentUser: Bool
    
    public init(rank: Int, isCurrentUser: Bool = false) {
        self.rank = rank
        self.isCurrentUser = isCurrentUser
    }
    
    private var displayText: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)."
        }
    }
    
    public var body: some View {
        Text(displayText)
            .font(rank <= 3 ? DSTypography.title3 : DSTypography.headline)
            .foregroundColor(isCurrentUser ? DSColors.primary : DSColors.textPrimary)
            .frame(minWidth: 32, alignment: .leading)
    }
}

// MARK: - Previews

#if DEBUG
struct DSStatusBadge_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                Group {
                    Text("Status Badges").dsHeadline()
                    HStack {
                        DSStatusBadge("Fully staffed", status: .success)
                        DSStatusBadge("Needs help", status: .warning)
                        DSStatusBadge("Critical", status: .critical)
                    }
                    HStack {
                        DSStatusBadge("Signed up", status: .signedUp)
                        DSStatusBadge("Info", status: .info)
                        DSStatusBadge("Neutral", status: .neutral)
                    }
                }
                
                Divider()
                
                Group {
                    Text("Staffing Badges").dsHeadline()
                    DSStaffingBadge(.fullyStaffed)
                    DSStaffingBadge(.needsHelp("Needs scouts"))
                    DSStaffingBadge(.critical)
                }
                
                Divider()
                
                Group {
                    Text("Role Badges").dsHeadline()
                    HStack {
                        DSRoleBadge(.parent)
                        DSRoleBadge(.scout)
                        DSRoleBadge(.admin)
                    }
                    HStack {
                        DSRoleBadge(.claimed)
                        DSRoleBadge(.unclaimed)
                    }
                }
                
                Divider()
                
                Group {
                    Text("Check-In Status").dsHeadline()
                    DSCheckInStatusBadge(.notCheckedIn)
                    DSCheckInStatusBadge(.checkedIn(time: "9:58 AM"))
                    DSCheckInStatusBadge(.checkedOut(time: "1:05 PM"))
                    DSCheckInStatusBadge(.noShow)
                }
                
                Divider()
                
                Group {
                    Text("Staffing Counts").dsHeadline()
                    HStack {
                        DSStaffingCountBadge(type: .scout, current: 2, required: 3)
                        DSStaffingCountBadge(type: .parent, current: 2, required: 2)
                    }
                }
                
                Divider()
                
                Group {
                    Text("Leaderboard Ranks").dsHeadline()
                    VStack(alignment: .leading) {
                        HStack {
                            DSRankBadge(rank: 1)
                            Text("Alex Smith")
                        }
                        HStack {
                            DSRankBadge(rank: 2)
                            Text("Emma Wilson")
                        }
                        HStack {
                            DSRankBadge(rank: 3)
                            Text("Jake Thompson")
                        }
                        HStack {
                            DSRankBadge(rank: 4, isCurrentUser: true)
                            Text("Sarah Smith (you)")
                        }
                    }
                }
            }
            .padding()
        }
    }
}
#endif
