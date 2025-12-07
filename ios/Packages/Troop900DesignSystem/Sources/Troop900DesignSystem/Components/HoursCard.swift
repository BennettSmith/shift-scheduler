import SwiftUI

// MARK: - Design System Hours Cards
// Based on Troop 900 iOS UI Design Specification

/// A card displaying hours summary (used in Profile tab).
public struct DSHoursCard: View {
    private let totalHours: Double
    private let thisWeek: Double
    private let lastWeek: Double
    private let earlier: Double
    private let upcoming: Double
    
    public init(
        totalHours: Double,
        thisWeek: Double,
        lastWeek: Double,
        earlier: Double,
        upcoming: Double
    ) {
        self.totalHours = totalHours
        self.thisWeek = thisWeek
        self.lastWeek = lastWeek
        self.earlier = earlier
        self.upcoming = upcoming
    }
    
    public var body: some View {
        DSSectionCard(title: "My Hours") {
            VStack(spacing: DSSpacing.md) {
                // Hero stat
                VStack(spacing: DSSpacing.xs) {
                    Text(String(format: "%.1f hours", totalHours))
                        .font(DSTypography.title1)
                        .foregroundColor(DSColors.textPrimary)
                    
                    Text("this season")
                        .font(DSTypography.caption1)
                        .foregroundColor(DSColors.textTertiary)
                }
                .padding(.vertical, DSSpacing.sm)
                
                // Breakdown
                VStack(spacing: DSSpacing.sm) {
                    DSHoursRow(label: "This Week", hours: thisWeek)
                    DSHoursRow(label: "Last Week", hours: lastWeek)
                    DSHoursRow(label: "Earlier", hours: earlier)
                    
                    DSDivider()
                    
                    DSHoursRow(label: "Upcoming", hours: upcoming, suffix: "scheduled", isHighlighted: true)
                }
            }
        }
    }
}

/// A single row in the hours breakdown.
public struct DSHoursRow: View {
    private let label: String
    private let hours: Double
    private let suffix: String
    private let isHighlighted: Bool
    
    public init(
        label: String,
        hours: Double,
        suffix: String = "hrs",
        isHighlighted: Bool = false
    ) {
        self.label = label
        self.hours = hours
        self.suffix = suffix
        self.isHighlighted = isHighlighted
    }
    
    public var body: some View {
        HStack {
            Text(label)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textPrimary)
            
            Spacer()
            
            Text(String(format: "%.1f %@", hours, suffix))
                .font(DSTypography.body)
                .foregroundColor(isHighlighted ? DSColors.primary : DSColors.textSecondary)
        }
    }
}

// MARK: - Leaderboard Summary Card

/// A card showing leaderboard rankings summary.
public struct DSLeaderboardSummaryCard: View {
    private let individualRank: Int
    private let individualTotal: Int
    private let familyRank: Int
    private let familyTotal: Int
    private let action: () -> Void
    
    public init(
        individualRank: Int,
        individualTotal: Int,
        familyRank: Int,
        familyTotal: Int,
        action: @escaping () -> Void
    ) {
        self.individualRank = individualRank
        self.individualTotal = individualTotal
        self.familyRank = familyRank
        self.familyTotal = familyTotal
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            DSSectionCard(title: "Leaderboards") {
                VStack(spacing: DSSpacing.sm) {
                    DSLeaderboardRankRow(
                        icon: .profileFill,
                        label: "Individual",
                        rank: individualRank,
                        total: individualTotal
                    )
                    
                    DSLeaderboardRankRow(
                        icon: .family,
                        label: "Family",
                        rank: familyRank,
                        total: familyTotal
                    )
                }
            }
        }
        .buttonStyle(.plain)
    }
}

/// A row showing rank in leaderboard summary.
public struct DSLeaderboardRankRow: View {
    private let icon: DSIcon
    private let label: String
    private let rank: Int
    private let total: Int
    
    public init(icon: DSIcon, label: String, rank: Int, total: Int) {
        self.icon = icon
        self.label = label
        self.rank = rank
        self.total = total
    }
    
    public var body: some View {
        HStack(spacing: DSSpacing.md) {
            DSIconView(icon, size: .medium, color: DSColors.textSecondary)
            
            Text(label)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textPrimary)
            
            Spacer()
            
            Text("#\(rank) of \(total)")
                .font(DSTypography.body)
                .foregroundColor(DSColors.textSecondary)
            
            DSIconView(.chevronRight, size: .small, color: DSColors.textTertiary)
        }
    }
}

// MARK: - Stats Card (for Committee dashboard)

/// A card showing key statistics.
public struct DSStatsCard: View {
    public struct Stat: Identifiable {
        public let id = UUID()
        public let value: String
        public let label: String
        
        public init(value: String, label: String) {
            self.value = value
            self.label = label
        }
    }
    
    private let stats: [Stat]
    
    public init(stats: [Stat]) {
        self.stats = stats
    }
    
    public var body: some View {
        DSCard {
            HStack(spacing: 0) {
                ForEach(Array(stats.enumerated()), id: \.element.id) { index, stat in
                    if index > 0 {
                        Divider()
                            .frame(height: 40)
                    }
                    
                    VStack(spacing: DSSpacing.xs) {
                        Text(stat.value)
                            .font(DSTypography.title1)
                            .foregroundColor(DSColors.textPrimary)
                        
                        Text(stat.label)
                            .font(DSTypography.caption1)
                            .foregroundColor(DSColors.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

// MARK: - Participation Stats Card

/// A card showing participation statistics.
public struct DSParticipationCard: View {
    public struct ParticipationRow {
        public let label: String
        public let value: String
        
        public init(label: String, value: String) {
            self.label = label
            self.value = value
        }
    }
    
    private let title: String
    private let rows: [ParticipationRow]
    
    public init(title: String, rows: [ParticipationRow]) {
        self.title = title
        self.rows = rows
    }
    
    public var body: some View {
        DSSectionCard(title: title) {
            VStack(spacing: DSSpacing.sm) {
                ForEach(rows.indices, id: \.self) { index in
                    HStack {
                        Text(rows[index].label)
                            .font(DSTypography.body)
                            .foregroundColor(DSColors.textPrimary)
                        
                        Spacer()
                        
                        Text(rows[index].value)
                            .font(DSTypography.body)
                            .foregroundColor(DSColors.textSecondary)
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
struct DSHoursCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: DSSpacing.lg) {
                DSHoursCard(
                    totalHours: 12.5,
                    thisWeek: 3.5,
                    lastWeek: 5.0,
                    earlier: 4.0,
                    upcoming: 6.0
                )
                
                DSLeaderboardSummaryCard(
                    individualRank: 4,
                    individualTotal: 32,
                    familyRank: 2,
                    familyTotal: 15
                ) { }
                
                DSStatsCard(stats: [
                    .init(value: "72", label: "shifts"),
                    .init(value: "486", label: "hours"),
                    .init(value: "15", label: "families")
                ])
                
                DSParticipationCard(
                    title: "Participation",
                    rows: [
                        .init(label: "Active Scouts", value: "28 / 32"),
                        .init(label: "Active Parents", value: "24 / 38"),
                        .init(label: "Avg Hours per Scout", value: "8.2 hrs"),
                        .init(label: "Avg Hours per Family", value: "32.4 hrs")
                    ]
                )
            }
            .padding()
        }
        .background(DSColors.neutral100)
    }
}
#endif
