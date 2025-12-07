//
//  ButtonsShowcase.swift
//  Troop900UIShowcase
//

import SwiftUI
import Troop900DesignSystem

struct ButtonsShowcase: View {
    @State private var isLoading = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                
                // Primary Buttons
                showcaseSection("Primary Buttons") {
                    VStack(spacing: DSSpacing.md) {
                        DSPrimaryButton("Sign Up") { }
                        DSPrimaryButton("Confirm Sign Up", icon: .success) { }
                        DSPrimaryButton("Loading...", isLoading: true) { }
                        DSPrimaryButton("Disabled", isDisabled: true) { }
                    }
                }
                
                // Primary Button Sizes
                showcaseSection("Primary Button Sizes") {
                    VStack(spacing: DSSpacing.md) {
                        DSPrimaryButton("Regular Size", size: .regular) { }
                        DSPrimaryButton("Small Size", size: .small) { }
                        DSPrimaryButton("Compact Size", size: .compact) { }
                    }
                }
                
                // Secondary Buttons
                showcaseSection("Secondary Buttons") {
                    VStack(spacing: DSSpacing.md) {
                        DSSecondaryButton("Cancel") { }
                        DSSecondaryButton("View Schedule", icon: .calendar) { }
                        DSSecondaryButton("Loading...", isLoading: true) { }
                        DSSecondaryButton("Disabled", isDisabled: true) { }
                    }
                }
                
                // Destructive Buttons
                showcaseSection("Destructive Buttons") {
                    VStack(spacing: DSSpacing.md) {
                        DSDestructiveButton("Cancel Signup", isFullWidth: true) { }
                        DSDestructiveButton("Sign Out", icon: .signOut, isFullWidth: true) { }
                        DSDestructiveButton("Delete", icon: .delete) { }
                    }
                }
                
                // Text Buttons
                showcaseSection("Text Buttons") {
                    VStack(alignment: .leading, spacing: DSSpacing.md) {
                        DSTextButton("Find a shift →") { }
                        DSTextButton("View Details", icon: .chevronRight) { }
                        DSTextButton("Learn More", color: DSColors.info) { }
                    }
                }
                
                // Icon Buttons
                showcaseSection("Icon Buttons") {
                    HStack(spacing: DSSpacing.lg) {
                        DSIconButton(icon: .close, color: DSColors.textSecondary) { }
                        DSIconButton(icon: .edit, color: DSColors.primary) { }
                        DSIconButton(icon: .delete, color: DSColors.error) { }
                        DSIconButton(icon: .share, color: DSColors.info) { }
                    }
                }
                
                // Check In/Out Buttons
                showcaseSection("Check In/Out Buttons") {
                    HStack(spacing: DSSpacing.lg) {
                        DSCheckInButton(mode: .checkIn) { }
                        DSCheckInButton(mode: .checkOut) { }
                    }
                    
                    HStack(spacing: DSSpacing.lg) {
                        DSCheckInButton(mode: .checkIn, isLoading: true) { }
                        DSCheckInButton(mode: .checkOut, isLoading: true) { }
                    }
                }
                
                // Interactive Demo
                showcaseSection("Interactive Demo") {
                    VStack(spacing: DSSpacing.md) {
                        DSPrimaryButton(isLoading ? "Processing..." : "Tap to Load", isLoading: isLoading) {
                            isLoading = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isLoading = false
                            }
                        }
                        
                        Text("Tap the button to see loading state")
                            .font(DSTypography.caption1)
                            .foregroundColor(DSColors.textTertiary)
                    }
                }
            }
            .padding()
        }
        .background(DSColors.neutral100)
        .navigationTitle("Buttons")
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
        ButtonsShowcase()
    }
}
