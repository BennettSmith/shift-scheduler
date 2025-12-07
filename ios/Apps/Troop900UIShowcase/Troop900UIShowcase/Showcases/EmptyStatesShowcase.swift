//
//  EmptyStatesShowcase.swift
//  Troop900UIShowcase
//

import SwiftUI
import Troop900DesignSystem

struct EmptyStatesShowcase: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                
                // No Shifts Today
                showcaseSection("No Shifts Today") {
                    DSCard {
                        DSEmptyState.noShiftsToday { }
                    }
                }
                
                // No Upcoming Shifts
                showcaseSection("No Upcoming Shifts") {
                    DSCard {
                        DSEmptyState.noUpcomingShifts { }
                    }
                }
                
                // Lot Closed
                showcaseSection("Lot Closed") {
                    DSCard {
                        DSEmptyState.lotClosed(nextOpenInfo: "The lot opens again tomorrow at 10 AM") { }
                    }
                }
                
                // No Search Results
                showcaseSection("No Search Results") {
                    DSCard {
                        DSEmptyState.noSearchResults(searchTerm: "John")
                    }
                }
                
                // Network Error
                showcaseSection("Network Error") {
                    DSCard {
                        DSEmptyState.networkError { }
                    }
                }
                
                // Server Error
                showcaseSection("Server Error") {
                    DSCard {
                        DSEmptyState.serverError { }
                    }
                }
                
                // Custom Empty State
                showcaseSection("Custom Empty State") {
                    DSCard {
                        DSEmptyState(
                            icon: .announcement,
                            title: "No Announcements",
                            message: "You're all caught up!",
                            actionTitle: nil,
                            action: nil
                        )
                    }
                }
                
                // Inline Empty States
                showcaseSection("Inline Empty States") {
                    DSCard {
                        DSInlineEmptyState("No shifts scheduled")
                    }
                    
                    DSCard {
                        DSInlineEmptyState(
                            "No upcoming shifts",
                            actionTitle: "Find a shift →"
                        ) { }
                    }
                }
            }
            .padding()
        }
        .background(DSColors.neutral100)
        .navigationTitle("Empty States")
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
        EmptyStatesShowcase()
    }
}
