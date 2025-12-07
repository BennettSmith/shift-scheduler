//
//  OfflineShowcase.swift
//  Troop900UIShowcase
//

import SwiftUI
import Troop900DesignSystem

struct OfflineShowcase: View {
    @State private var isOffline = true
    @State private var bannerVisible = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                
                // Toggle
                showcaseSection("Simulate Offline") {
                    DSCard {
                        DSToggleRow(
                            title: "Offline Mode",
                            subtitle: "Toggle to see offline states",
                            isOn: $isOffline
                        )
                    }
                }
                
                // Offline Banner
                showcaseSection("Offline Banner") {
                    VStack(spacing: DSSpacing.md) {
                        DSOfflineBanner(
                            isVisible: $bannerVisible,
                            message: "You're offline. Some features are unavailable."
                        )
                        
                        if !bannerVisible {
                            DSSecondaryButton("Show Banner Again") {
                                bannerVisible = true
                            }
                        }
                    }
                }
                
                // Check-In Offline Banner
                showcaseSection("Check-In Offline Banner") {
                    DSCheckInOfflineBanner(isVisible: .constant(true))
                }
                
                // Stale Data Indicator
                showcaseSection("Stale Data Indicator") {
                    DSCard {
                        HStack {
                            Text("STAFFING")
                                .font(DSTypography.caption1)
                                .foregroundColor(DSColors.textTertiary)
                            
                            Spacer()
                            
                            DSStaleDataIndicator(lastUpdated: Date().addingTimeInterval(-300))
                        }
                        .padding(.bottom, DSSpacing.sm)
                        
                        Text("When offline, shows when data was last synced")
                            .font(DSTypography.body)
                            .foregroundColor(DSColors.textSecondary)
                    }
                }
                
                // Disabled Action View
                showcaseSection("Disabled Actions (Offline)") {
                    DSOfflineDisabledView(isOffline: isOffline) {
                        DSPrimaryButton("Sign Up") { }
                    }
                    
                    DSOfflineDisabledView(isOffline: isOffline) {
                        DSSecondaryButton("Cancel Signup") { }
                    }
                }
                
                // Example: Roster View Offline
                showcaseSection("Roster View (Offline Mode)") {
                    VStack(spacing: 0) {
                        if isOffline {
                            DSCheckInOfflineBanner(isVisible: .constant(true))
                        }
                        
                        DSGroupedList {
                            HStack {
                                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                                    Text("John Davis")
                                        .font(DSTypography.headline)
                                        .foregroundColor(DSColors.textPrimary)
                                    DSCheckInStatusBadge(.checkedIn(time: "8:58 AM"))
                                }
                                Spacer()
                                // No button when offline
                                if !isOffline {
                                    DSCheckInButton(mode: .checkOut) { }
                                }
                            }
                            .padding(DSSpacing.md)
                            
                            DSDivider()
                            
                            HStack {
                                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                                    Text("Sarah Smith")
                                        .font(DSTypography.headline)
                                        .foregroundColor(DSColors.textPrimary)
                                    if isOffline {
                                        Text("Status unknown while offline")
                                            .font(DSTypography.caption1)
                                            .foregroundColor(DSColors.textTertiary)
                                    } else {
                                        DSCheckInStatusBadge(.notCheckedIn)
                                    }
                                }
                                Spacer()
                                if !isOffline {
                                    DSCheckInButton(mode: .checkIn) { }
                                }
                            }
                            .padding(DSSpacing.md)
                        }
                    }
                }
            }
            .padding()
        }
        .background(DSColors.neutral100)
        .navigationTitle("Offline States")
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
        OfflineShowcase()
    }
}
