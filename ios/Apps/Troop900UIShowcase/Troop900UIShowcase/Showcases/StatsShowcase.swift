//
//  StatsShowcase.swift
//  Troop900UIShowcase
//

import SwiftUI
import Troop900DesignSystem

struct StatsShowcase: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                
                // Hours Card
                showcaseSection("Hours Card") {
                    DSHoursCard(
                        totalHours: 12.5,
                        thisWeek: 3.5,
                        lastWeek: 5.0,
                        earlier: 4.0,
                        upcoming: 6.0
                    )
                }
                
                // Hours Row
                showcaseSection("Hours Rows") {
                    DSCard {
                        VStack(spacing: DSSpacing.sm) {
                            DSHoursRow(label: "This Week", hours: 3.5)
                            DSHoursRow(label: "Last Week", hours: 5.0)
                            DSHoursRow(label: "Earlier", hours: 4.0)
                            DSDivider()
                            DSHoursRow(label: "Upcoming", hours: 6.0, suffix: "scheduled", isHighlighted: true)
                        }
                    }
                }
                
                // Leaderboard Summary Card
                showcaseSection("Leaderboard Summary Card") {
                    DSLeaderboardSummaryCard(
                        individualRank: 4,
                        individualTotal: 32,
                        familyRank: 2,
                        familyTotal: 15
                    ) { }
                }
                
                // Stats Card
                showcaseSection("Stats Card (3 columns)") {
                    DSStatsCard(stats: [
                        .init(value: "72", label: "shifts"),
                        .init(value: "486", label: "hours"),
                        .init(value: "15", label: "families")
                    ])
                }
                
                // Stats Card (2 columns)
                showcaseSection("Stats Card (2 columns)") {
                    DSStatsCard(stats: [
                        .init(value: "486.5", label: "total hours"),
                        .init(value: "32", label: "scouts")
                    ])
                }
                
                // Participation Card
                showcaseSection("Participation Card") {
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
                
                // Shift Coverage Card
                showcaseSection("Shift Coverage Card") {
                    DSParticipationCard(
                        title: "Shift Coverage",
                        rows: [
                            .init(label: "Fully Staffed", value: "58 / 72 (81%)"),
                            .init(label: "Understaffed", value: "14 / 72 (19%)"),
                            .init(label: "Average Fill Rate", value: "94%")
                        ]
                    )
                }
                
                // Combined Example: Season Statistics
                showcaseSection("Combined: Season Statistics") {
                    VStack(spacing: DSSpacing.md) {
                        VStack(alignment: .leading, spacing: DSSpacing.sm) {
                            Text("2024 Tree Lot Season")
                                .font(DSTypography.title2)
                            Text("Nov 25 - Dec 23")
                                .font(DSTypography.callout)
                                .foregroundColor(DSColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        DSStatsCard(stats: [
                            .init(value: "72", label: "shifts"),
                            .init(value: "486", label: "hours"),
                            .init(value: "15", label: "families")
                        ])
                        
                        DSParticipationCard(
                            title: "Participation",
                            rows: [
                                .init(label: "Active Scouts", value: "28 / 32"),
                                .init(label: "Active Parents", value: "24 / 38")
                            ]
                        )
                    }
                }
            }
            .padding()
        }
        .background(DSColors.neutral100)
        .navigationTitle("Hours & Stats")
    }
    
    @ViewBuilder
    private func showcaseSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            Text(title)
                .font(DSTypography.headline)
                .foregroundColor(DSColors.textPrimary)
            
            content()
        }
    }
}

#Preview {
    NavigationStack {
        StatsShowcase()
    }
}
