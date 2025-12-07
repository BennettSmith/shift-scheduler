//
//  ListShowcase.swift
//  Troop900UIShowcase
//

import SwiftUI
import Troop900DesignSystem

struct ListShowcase: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                
                // Section Headers
                showcaseSection("Section Headers") {
                    DSSectionHeader("Parents")
                    DSSectionHeader("Scouts", trailing: "2 total")
                    DSDayHeader(date: Date())
                }
                
                // Navigation Rows
                showcaseSection("Navigation Rows") {
                    DSGroupedList {
                        DSNavigationRow(
                            icon: .settings,
                            title: "Settings",
                            action: { }
                        )
                        DSDivider()
                        DSNavigationRow(
                            icon: .help,
                            title: "Help & Support",
                            subtitle: "Get help with the app",
                            action: { }
                        )
                        DSDivider()
                        DSNavigationRow(
                            title: "Privacy Policy",
                            action: { }
                        )
                    }
                }
                
                // Info Rows
                showcaseSection("Info Rows (Static)") {
                    DSGroupedList {
                        DSInfoRow(label: "App Version", value: "1.0.0")
                        DSDivider()
                        DSInfoRow(label: "Build", value: "2024.12.1")
                        DSDivider()
                        DSInfoRow(label: "Family Unit ID", value: "smith-2024")
                    }
                }
                
                // Person Rows
                showcaseSection("Person Rows") {
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
                            subtitle: "david@email.com",
                            badge: .spouse,
                            action: { }
                        )
                    }
                    
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
                
                // Roster Rows
                showcaseSection("Roster Rows (Check-In)") {
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
                        DSDivider()
                        DSRosterRow(
                            name: "Alex Smith",
                            status: .checkedOut(time: "1:05 PM"),
                            button: nil
                        )
                    }
                }
                
                // Leaderboard Rows
                showcaseSection("Leaderboard Rows") {
                    VStack(spacing: 0) {
                        DSLeaderboardRow(rank: 1, name: "Alex Smith", hours: 18.5)
                        DSLeaderboardRow(rank: 2, name: "Emma Wilson", hours: 16.0)
                        DSLeaderboardRow(rank: 3, name: "Jake Thompson", hours: 14.5)
                        DSLeaderboardRow(rank: 4, name: "Sarah Smith (you)", hours: 12.5, isCurrentUser: true)
                        DSLeaderboardRow(rank: 5, name: "John Davis", hours: 11.0)
                    }
                }
            }
            .padding()
        }
        .background(DSColors.neutral100)
        .navigationTitle("List Components")
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
        ListShowcase()
    }
}
