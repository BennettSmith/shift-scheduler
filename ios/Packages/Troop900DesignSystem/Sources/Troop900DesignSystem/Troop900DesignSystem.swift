// Troop900DesignSystem
// A comprehensive design system for the Troop 900 Tree Lot Scheduler iOS app.
//
// Based on the Troop 900 iOS UI Design Specification (December 2024)
//
// This package provides:
// - Design tokens (colors, typography, spacing, icons)
// - Reusable UI components (buttons, cards, badges, forms)
// - Consistent styling across the app
//
// Usage:
//   import Troop900DesignSystem
//
//   // Use design tokens
//   Text("Hello").foregroundColor(DSColors.primary)
//   Text("Hello").font(DSTypography.headline)
//
//   // Use components
//   DSPrimaryButton("Sign Up") { }
//   DSCard { ... }
//   DSStatusBadge("Fully staffed", status: .success)

import SwiftUI

// MARK: - Module Exports

// All public types are exported automatically through their respective files:
//
// Tokens:
// - DSColors: Color palette with semantic colors
// - DSTypography: Text styles using San Francisco font
// - DSSpacing: Spacing scale (xs, sm, md, lg, xl, xxl)
// - DSRadius: Corner radius values
// - DSShadow: Shadow definitions
// - DSIcon: SF Symbol icon names
// - DSIconView: Icon view component
//
// Components:
// - Buttons: DSPrimaryButton, DSSecondaryButton, DSDestructiveButton, DSTextButton, DSIconButton
// - Cards: DSCard, DSSectionCard, DSInfoCard, DSAlertCard, DSTappableCardRow
// - Status: DSStatusBadge, DSStaffingBadge, DSRoleBadge, DSCheckInStatusBadge
// - Empty States: DSEmptyState, DSInlineEmptyState
// - Toast: DSToast, DSToastData, DSToastManager
// - Offline: DSOfflineBanner, DSStaleDataIndicator, DSOfflineDisabledView
// - Loading: DSLoadingSpinner, DSSkeleton, DSSkeletonCard, etc.
// - Forms: DSTextField, DSTextArea, DSSearchField, DSToggleRow, DSStepperRow, etc.
// - Lists: DSSectionHeader, DSNavigationRow, DSPersonRow, DSRosterRow, etc.
// - Sheets: DSSheet, DSSheetHeader, DSConfirmationDialog, DSSuccessSheet
// - Avatar: DSAvatar, DSProfileHeader
// - Shift Cards: DSShiftCard, DSFamilyShiftCard, DSWeekCard, DSCurrentShiftCard
// - Hours: DSHoursCard, DSLeaderboardSummaryCard, DSStatsCard

// MARK: - Design System Version

/// The current version of the design system.
public let designSystemVersion = "1.0.0"

// MARK: - Environment Keys

/// Environment key for the toast manager.
@MainActor
private struct ToastManagerKey: EnvironmentKey {
    static let defaultValue: DSToastManager = DSToastManager()
}

@MainActor
public extension EnvironmentValues {
    /// Access the toast manager from the environment.
    var toastManager: DSToastManager {
        get { self[ToastManagerKey.self] }
        set { self[ToastManagerKey.self] = newValue }
    }
}

// MARK: - Preview Helpers

#if DEBUG
/// A preview container with standard design system styling.
public struct DSPreviewContainer<Content: View>: View {
    private let title: String
    private let content: Content
    
    public init(_ title: String = "Preview", @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                content
                    .padding()
            }
            .background(DSColors.neutral100)
            .navigationTitle(title)
        }
    }
}

/// Preview all design system colors.
public struct DSColorPalettePreview: View {
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            Group {
                Text("Primary Colors").dsHeadline()
                HStack {
                    ColorSwatch(color: DSColors.primary, name: "Primary")
                    ColorSwatch(color: DSColors.primaryDark, name: "Primary Dark")
                    ColorSwatch(color: DSColors.primaryLight, name: "Primary Light")
                }
            }
            
            Group {
                Text("Semantic Colors").dsHeadline()
                HStack {
                    ColorSwatch(color: DSColors.success, name: "Success")
                    ColorSwatch(color: DSColors.warning, name: "Warning")
                    ColorSwatch(color: DSColors.error, name: "Error")
                    ColorSwatch(color: DSColors.info, name: "Info")
                }
            }
            
            Group {
                Text("Neutral Colors").dsHeadline()
                HStack {
                    ColorSwatch(color: DSColors.neutral900, name: "900")
                    ColorSwatch(color: DSColors.neutral700, name: "700")
                    ColorSwatch(color: DSColors.neutral500, name: "500")
                    ColorSwatch(color: DSColors.neutral300, name: "300")
                    ColorSwatch(color: DSColors.neutral200, name: "200")
                    ColorSwatch(color: DSColors.neutral100, name: "100")
                }
            }
        }
    }
    
    struct ColorSwatch: View {
        let color: Color
        let name: String
        
        var body: some View {
            VStack {
                RoundedRectangle(cornerRadius: DSRadius.sm)
                    .fill(color)
                    .frame(width: 50, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: DSRadius.sm)
                            .stroke(DSColors.neutral200, lineWidth: 1)
                    )
                Text(name)
                    .font(DSTypography.caption2)
                    .foregroundColor(DSColors.textSecondary)
            }
        }
    }
}

/// Preview all typography styles.
public struct DSTypographyPreview: View {
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            Text("Large Title").font(DSTypography.largeTitle)
            Text("Title 1").font(DSTypography.title1)
            Text("Title 2").font(DSTypography.title2)
            Text("Title 3").font(DSTypography.title3)
            Text("Headline").font(DSTypography.headline)
            Text("Body").font(DSTypography.body)
            Text("Callout").font(DSTypography.callout)
            Text("Subhead").font(DSTypography.subhead)
            Text("Footnote").font(DSTypography.footnote)
            Text("Caption 1").font(DSTypography.caption1)
            Text("Caption 2").font(DSTypography.caption2)
        }
    }
}
#endif
