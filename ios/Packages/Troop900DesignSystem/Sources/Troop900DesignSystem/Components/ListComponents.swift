import SwiftUI

// MARK: - Design System List Components
// Based on Troop 900 iOS UI Design Specification

/// A section header for grouped content (uppercase, caption style).
public struct DSSectionHeader: View {
    private let title: String
    private let trailing: String?
    
    public init(_ title: String, trailing: String? = nil) {
        self.title = title
        self.trailing = trailing
    }
    
    public var body: some View {
        HStack {
            Text(title.uppercased())
                .font(DSTypography.caption1)
                .foregroundColor(DSColors.textTertiary)
                .tracking(0.5)
            
            Spacer()
            
            if let trailing = trailing {
                Text(trailing)
                    .font(DSTypography.caption1)
                    .foregroundColor(DSColors.textTertiary)
            }
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.top, DSSpacing.lg)
        .padding(.bottom, DSSpacing.sm)
    }
}

// MARK: - Day Header

/// A day header for schedule views (e.g., "MONDAY, NOV 25").
public struct DSDayHeader: View {
    private let date: Date
    
    public init(date: Date) {
        self.date = date
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date).uppercased()
    }
    
    public var body: some View {
        Text(formattedDate)
            .font(DSTypography.subhead)
            .foregroundColor(DSColors.textTertiary)
            .padding(.horizontal, DSSpacing.md)
            .padding(.top, DSSpacing.lg)
            .padding(.bottom, DSSpacing.sm)
    }
}

// MARK: - Navigation Row

/// A row that navigates to another screen.
public struct DSNavigationRow: View {
    private let icon: DSIcon?
    private let title: String
    private let subtitle: String?
    private let trailing: String?
    private let action: () -> Void
    
    public init(
        icon: DSIcon? = nil,
        title: String,
        subtitle: String? = nil,
        trailing: String? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.md) {
                if let icon = icon {
                    DSIconView(icon, size: .medium, color: DSColors.textSecondary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(DSTypography.body)
                        .foregroundColor(DSColors.textPrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(DSTypography.caption1)
                            .foregroundColor(DSColors.textTertiary)
                    }
                }
                
                Spacer()
                
                if let trailing = trailing {
                    Text(trailing)
                        .font(DSTypography.body)
                        .foregroundColor(DSColors.textTertiary)
                }
                
                DSIconView(.chevronRight, size: .small, color: DSColors.textTertiary)
            }
            .padding(DSSpacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Info Row

/// A static info row (label + value, no navigation).
public struct DSInfoRow: View {
    private let label: String
    private let value: String
    
    public init(label: String, value: String) {
        self.label = label
        self.value = value
    }
    
    public var body: some View {
        HStack {
            Text(label)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textTertiary)
        }
        .padding(DSSpacing.md)
    }
}

// MARK: - Person Row

/// A row displaying a person (for rosters, family lists, etc.).
public struct DSPersonRow: View {
    public enum PersonType {
        case scout
        case parent
        case unknown
        
        var icon: DSIcon {
            switch self {
            case .scout: return .scout
            case .parent, .unknown: return .profile
            }
        }
    }
    
    private let name: String
    private let type: PersonType
    private let subtitle: String?
    private let badge: DSRoleBadge.Role?
    private let trailing: AnyView?
    private let action: (() -> Void)?
    
    public init(
        name: String,
        type: PersonType,
        subtitle: String? = nil,
        badge: DSRoleBadge.Role? = nil,
        trailing: AnyView? = nil,
        action: (() -> Void)? = nil
    ) {
        self.name = name
        self.type = type
        self.subtitle = subtitle
        self.badge = badge
        self.trailing = trailing
        self.action = action
    }
    
    public var body: some View {
        let content = HStack(spacing: DSSpacing.md) {
            DSIconView(type.icon, size: .medium, color: DSColors.textSecondary)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: DSSpacing.sm) {
                    Text(name)
                        .font(DSTypography.headline)
                        .foregroundColor(DSColors.textPrimary)
                    
                    if let badge = badge {
                        DSRoleBadge(badge)
                    }
                }
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(DSTypography.caption1)
                        .foregroundColor(DSColors.textTertiary)
                }
            }
            
            Spacer()
            
            if let trailing = trailing {
                trailing
            }
            
            if action != nil {
                DSIconView(.chevronRight, size: .small, color: DSColors.textTertiary)
            }
        }
        .padding(DSSpacing.md)
        
        if let action = action {
            Button(action: action) {
                content
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        } else {
            content
        }
    }
}

// MARK: - Roster Row (for check-in screen)

/// A roster row showing a person with check-in status and action button.
public struct DSRosterRow: View {
    private let name: String
    private let status: DSCheckInStatusBadge.Status
    private let button: AnyView?
    
    public init(
        name: String,
        status: DSCheckInStatusBadge.Status,
        button: AnyView? = nil
    ) {
        self.name = name
        self.status = status
        self.button = button
    }
    
    public var body: some View {
        HStack(spacing: DSSpacing.md) {
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(name)
                    .font(DSTypography.headline)
                    .foregroundColor(DSColors.textPrimary)
                
                DSCheckInStatusBadge(status)
            }
            
            Spacer()
            
            if let button = button {
                button
            }
        }
        .padding(DSSpacing.md)
    }
}

// MARK: - Leaderboard Row

/// A row in the leaderboard list.
public struct DSLeaderboardRow: View {
    private let rank: Int
    private let name: String
    private let hours: Double
    private let isCurrentUser: Bool
    
    public init(
        rank: Int,
        name: String,
        hours: Double,
        isCurrentUser: Bool = false
    ) {
        self.rank = rank
        self.name = name
        self.hours = hours
        self.isCurrentUser = isCurrentUser
    }
    
    public var body: some View {
        HStack(spacing: DSSpacing.md) {
            DSRankBadge(rank: rank, isCurrentUser: isCurrentUser)
            
            Text(name)
                .font(DSTypography.body)
                .foregroundColor(isCurrentUser ? DSColors.primary : DSColors.textPrimary)
            
            Spacer()
            
            Text(String(format: "%.1f hrs", hours))
                .font(DSTypography.body)
                .foregroundColor(DSColors.textSecondary)
        }
        .padding(DSSpacing.md)
        .background(isCurrentUser ? DSColors.primaryLight : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
    }
}

// MARK: - Divider

/// A styled divider.
public struct DSDivider: View {
    private let color: Color
    
    public init(color: Color = DSColors.neutral200) {
        self.color = color
    }
    
    public var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: 1)
    }
}

// MARK: - Grouped List Container

/// A container that groups rows with proper styling.
public struct DSGroupedList<Content: View>: View {
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(DSColors.backgroundElevated)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
        .shadowMd()
    }
}

// MARK: - Previews

#if DEBUG
struct DSListComponents_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: DSSpacing.lg) {
                Group {
                    DSSectionHeader("Parents")
                    
                    DSGroupedList {
                        DSPersonRow(
                            name: "Sarah Smith (you)",
                            type: .parent,
                            badge: .primary
                        )
                        DSDivider()
                        DSPersonRow(
                            name: "David Smith",
                            type: .parent,
                            badge: .spouse,
                            action: { }
                        )
                    }
                }
                
                Group {
                    DSSectionHeader("Scouts", trailing: "2 total")
                    
                    DSGroupedList {
                        DSPersonRow(
                            name: "Alex Smith",
                            type: .scout,
                            subtitle: "Has own account",
                            badge: .claimed,
                            action: { }
                        )
                        DSDivider()
                        DSPersonRow(
                            name: "Emma Smith",
                            type: .scout,
                            subtitle: "Claim code: TREE-EMMA-2024",
                            badge: .unclaimed,
                            action: { }
                        )
                    }
                }
                
                Group {
                    DSDayHeader(date: Date())
                    
                    DSGroupedList {
                        DSNavigationRow(icon: .settings, title: "Settings", action: { })
                        DSDivider()
                        DSNavigationRow(icon: .help, title: "Help & Support", action: { })
                        DSDivider()
                        DSInfoRow(label: "App Version", value: "1.0.0")
                    }
                }
                
                Group {
                    DSSectionHeader("Roster")
                    
                    DSGroupedList {
                        DSRosterRow(
                            name: "John Davis",
                            status: .checkedIn(time: "8:58 AM"),
                            button: AnyView(DSCheckInButton(mode: .checkOut) { })
                        )
                        DSDivider()
                        DSRosterRow(
                            name: "Sarah Smith",
                            status: .notCheckedIn,
                            button: AnyView(DSCheckInButton(mode: .checkIn) { })
                        )
                    }
                }
                
                Group {
                    DSSectionHeader("Leaderboard")
                    
                    VStack(spacing: 0) {
                        DSLeaderboardRow(rank: 1, name: "Alex Smith", hours: 18.5)
                        DSLeaderboardRow(rank: 2, name: "Emma Wilson", hours: 16.0)
                        DSLeaderboardRow(rank: 3, name: "Jake Thompson", hours: 14.5)
                        DSLeaderboardRow(rank: 4, name: "Sarah Smith (you)", hours: 12.5, isCurrentUser: true)
                    }
                }
            }
            .padding()
        }
        .background(DSColors.neutral100)
    }
}
#endif
