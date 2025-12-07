//
//  CardsShowcase.swift
//  Troop900UIShowcase
//

import SwiftUI
import Troop900DesignSystem

struct CardsShowcase: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                
                // Basic Card
                showcaseSection("Basic Card") {
                    DSCard {
                        VStack(alignment: .leading, spacing: DSSpacing.sm) {
                            Text("Card Title")
                                .font(DSTypography.headline)
                                .foregroundColor(DSColors.textPrimary)
                            Text("This is a basic card with default styling. Cards use a white background, medium corner radius, and medium shadow.")
                                .font(DSTypography.body)
                                .foregroundColor(DSColors.textSecondary)
                        }
                    }
                }
                
                // Card without Shadow
                showcaseSection("Card without Shadow") {
                    DSCard(hasShadow: false) {
                        VStack(alignment: .leading, spacing: DSSpacing.sm) {
                            Text("Flat Card")
                                .font(DSTypography.headline)
                                .foregroundColor(DSColors.textPrimary)
                            Text("This card has no shadow for a flatter look.")
                                .font(DSTypography.body)
                                .foregroundColor(DSColors.textSecondary)
                        }
                    }
                }
                
                // Section Card
                showcaseSection("Section Card") {
                    DSSectionCard(title: "Your Family's Shifts") {
                        VStack(alignment: .leading, spacing: DSSpacing.sm) {
                            Text("Content goes here...")
                                .font(DSTypography.body)
                                .foregroundColor(DSColors.textSecondary)
                        }
                    }
                    
                    DSSectionCard(title: "Leaderboards", actionTitle: "View All") {
                        Text("Content with action button")
                            .font(DSTypography.body)
                            .foregroundColor(DSColors.textSecondary)
                    }
                }
                
                // Info Cards
                showcaseSection("Info Cards") {
                    DSInfoCard("This is an informational message to help the user understand something.", style: .info)
                    
                    DSInfoCard("You're offline. Some features are unavailable.", style: .warning)
                    
                    DSInfoCard("Your signup has been confirmed!", style: .success)
                    
                    DSInfoCard("There was an error processing your request.", style: .error)
                }
                
                // Alert Card
                showcaseSection("Alert Card") {
                    DSAlertCard(
                        title: "Staffing Alerts",
                        message: "3 shifts critically understaffed this week",
                        style: .warning,
                        actionTitle: "View Alerts"
                    ) { }
                    
                    DSAlertCard(
                        title: "Error",
                        message: "Failed to load shifts. Please try again.",
                        style: .error,
                        actionTitle: "Retry"
                    ) { }
                }
                
                // Tappable Card Row
                showcaseSection("Tappable Card Row") {
                    DSTappableCardRow(action: { }) {
                        HStack {
                            DSIconView(.settings, size: .medium, color: DSColors.textSecondary)
                            VStack(alignment: .leading) {
                                Text("Settings")
                                    .font(DSTypography.headline)
                                    .foregroundColor(DSColors.textPrimary)
                                Text("Manage your preferences")
                                    .font(DSTypography.caption1)
                                    .foregroundColor(DSColors.textTertiary)
                            }
                        }
                    }
                    
                    DSTappableCardRow(showChevron: false, action: { }) {
                        HStack {
                            DSIconView(.info, size: .medium, color: DSColors.textSecondary)
                            Text("No chevron variant")
                                .font(DSTypography.headline)
                                .foregroundColor(DSColors.textPrimary)
                        }
                    }
                }
            }
            .padding()
        }
        .background(DSColors.neutral100)
        .navigationTitle("Cards")
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
        CardsShowcase()
    }
}
