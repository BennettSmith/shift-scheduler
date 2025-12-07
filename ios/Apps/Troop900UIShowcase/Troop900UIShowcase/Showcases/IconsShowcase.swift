//
//  IconsShowcase.swift
//  Troop900UIShowcase
//

import SwiftUI
import Troop900DesignSystem

struct IconsShowcase: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                
                // Tab Bar Icons
                showcaseSection("Tab Bar Icons") {
                    HStack(spacing: DSSpacing.xl) {
                        iconPair(inactive: .home, active: .homeFill, label: "Home")
                        iconPair(inactive: .calendar, active: .calendarFill, label: "Schedule")
                        iconPair(inactive: .checkIn, active: .checkInFill, label: "Check-In")
                        iconPair(inactive: .profile, active: .profileFill, label: "Profile")
                        iconPair(inactive: .committee, active: .committeeFill, label: "Committee")
                    }
                }
                
                // Entity Icons
                showcaseSection("Entity Icons") {
                    HStack(spacing: DSSpacing.xl) {
                        iconWithLabel(.scout, label: "Scout")
                        iconWithLabel(.parent, label: "Parent")
                        iconWithLabel(.people, label: "People")
                        iconWithLabel(.family, label: "Family")
                        iconWithLabel(.household, label: "Household")
                    }
                }
                
                // Status Icons
                showcaseSection("Status Icons") {
                    HStack(spacing: DSSpacing.xl) {
                        iconWithLabel(.success, label: "Success", color: DSColors.success)
                        iconWithLabel(.warning, label: "Warning", color: DSColors.warning)
                        iconWithLabel(.critical, label: "Critical", color: DSColors.error)
                        iconWithLabel(.starred, label: "Starred", color: DSColors.primary)
                        iconWithLabel(.star, label: "Star")
                    }
                }
                
                // Action Icons
                showcaseSection("Action Icons") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: DSSpacing.lg) {
                        iconWithLabel(.add, label: "Add")
                        iconWithLabel(.plus, label: "Plus")
                        iconWithLabel(.edit, label: "Edit")
                        iconWithLabel(.delete, label: "Delete")
                        iconWithLabel(.share, label: "Share")
                        iconWithLabel(.copy, label: "Copy")
                        iconWithLabel(.search, label: "Search")
                        iconWithLabel(.close, label: "Close")
                        iconWithLabel(.settings, label: "Settings")
                        iconWithLabel(.signOut, label: "Sign Out")
                    }
                }
                
                // Navigation Icons
                showcaseSection("Navigation Icons") {
                    HStack(spacing: DSSpacing.xl) {
                        iconWithLabel(.chevronRight, label: "Right")
                        iconWithLabel(.chevronDown, label: "Down")
                        iconWithLabel(.chevronUp, label: "Up")
                    }
                }
                
                // Misc Icons
                showcaseSection("Miscellaneous") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: DSSpacing.lg) {
                        iconWithLabel(.location, label: "Location")
                        iconWithLabel(.clock, label: "Clock")
                        iconWithLabel(.bell, label: "Bell")
                        iconWithLabel(.bellBadge, label: "Bell Badge")
                        iconWithLabel(.info, label: "Info")
                        iconWithLabel(.help, label: "Help")
                        iconWithLabel(.offline, label: "Offline")
                        iconWithLabel(.refresh, label: "Refresh")
                        iconWithLabel(.export, label: "Export")
                        iconWithLabel(.announcement, label: "Announce")
                        iconWithLabel(.document, label: "Document")
                        iconWithLabel(.chart, label: "Chart")
                    }
                }
                
                // Icon Sizes
                showcaseSection("Icon Sizes") {
                    HStack(spacing: DSSpacing.xl) {
                        VStack {
                            DSIconView(.homeFill, size: .small)
                            Text("Small").font(DSTypography.caption2)
                        }
                        VStack {
                            DSIconView(.homeFill, size: .medium)
                            Text("Medium").font(DSTypography.caption2)
                        }
                        VStack {
                            DSIconView(.homeFill, size: .large)
                            Text("Large").font(DSTypography.caption2)
                        }
                        VStack {
                            DSIconView(.homeFill, size: .xlarge)
                            Text("XLarge").font(DSTypography.caption2)
                        }
                        VStack {
                            DSIconView(.homeFill, size: .xxlarge)
                            Text("XXLarge").font(DSTypography.caption2)
                        }
                    }
                }
            }
            .padding()
        }
        .background(DSColors.neutral100)
        .navigationTitle("Icons")
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
    
    @ViewBuilder
    private func iconWithLabel(_ icon: DSIcon, label: String, color: Color = DSColors.textPrimary) -> some View {
        VStack(spacing: DSSpacing.xs) {
            DSIconView(icon, size: .large, color: color)
            Text(label)
                .font(DSTypography.caption2)
                .foregroundColor(DSColors.textSecondary)
        }
    }
    
    @ViewBuilder
    private func iconPair(inactive: DSIcon, active: DSIcon, label: String) -> some View {
        VStack(spacing: DSSpacing.xs) {
            HStack(spacing: DSSpacing.sm) {
                DSIconView(inactive, size: .medium, color: DSColors.textTertiary)
                DSIconView(active, size: .medium, color: DSColors.primary)
            }
            Text(label)
                .font(DSTypography.caption2)
                .foregroundColor(DSColors.textSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        IconsShowcase()
    }
}
