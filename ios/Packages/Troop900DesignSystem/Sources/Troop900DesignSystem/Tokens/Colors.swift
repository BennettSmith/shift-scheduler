import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Design System Colors
// Based on Troop 900 iOS UI Design Specification

/// The complete color palette for the Troop 900 Tree Lot app.
/// All colors are defined with their semantic purpose.
public enum DSColors {
    // MARK: - Primary (CalTrans Orange)
    
    /// Primary accent color - CalTrans Orange (#FF6D00)
    /// Use for buttons, active states, key actions
    public static let primary = Color(hex: 0xFF6D00)
    
    /// Primary dark color (#E65100)
    /// Use for pressed states and emphasis
    public static let primaryDark = Color(hex: 0xE65100)
    
    /// Primary light color (#FFF3E0) / Dark mode: darker orange tint
    /// Use for backgrounds and highlights
    public static let primaryLight = Color(adaptive: (light: 0xFFF3E0, dark: 0x3D2200))
    
    // MARK: - Neutrals (Raw Values)
    
    /// Neutral 900 (#1A1A1A)
    public static let neutral900 = Color(hex: 0x1A1A1A)
    
    /// Neutral 700 (#4A4A4A)
    public static let neutral700 = Color(hex: 0x4A4A4A)
    
    /// Neutral 500 (#8A8A8A)
    public static let neutral500 = Color(hex: 0x8A8A8A)
    
    /// Neutral 300 (#B0B0B0)
    public static let neutral300 = Color(hex: 0xB0B0B0)
    
    /// Neutral 200 (#E5E5E5)
    public static let neutral200 = Color(hex: 0xE5E5E5)
    
    /// Neutral 100 (#F5F5F5)
    public static let neutral100 = Color(adaptive: (light: 0xF5F5F5, dark: 0x1C1C1E))
    
    /// Neutral 0 / White (#FFFFFF)
    public static let neutral0 = Color(hex: 0xFFFFFF)
    
    // MARK: - Semantic Colors
    
    /// Success color (#2E7D32) / Dark mode: brighter green
    /// Checked in, confirmed, fully staffed
    public static let success = Color(adaptive: (light: 0x2E7D32, dark: 0x4CAF50))
    
    /// Success light background
    public static let successLight = Color(adaptive: (light: 0xE8F5E9, dark: 0x1B3D1F))
    
    /// Warning color (#F9A825)
    /// Needs attention, understaffed
    public static let warning = Color(hex: 0xF9A825)
    
    /// Warning light background
    public static let warningLight = Color(adaptive: (light: 0xFFF8E1, dark: 0x3D3000))
    
    /// Error color (#C62828) / Dark mode: brighter red
    /// Critical, errors, cancellations
    public static let error = Color(adaptive: (light: 0xC62828, dark: 0xEF5350))
    
    /// Error light background
    public static let errorLight = Color(adaptive: (light: 0xFFEBEE, dark: 0x3D1A1A))
    
    /// Info color (#1565C0) / Dark mode: brighter blue
    /// Informational states
    public static let info = Color(adaptive: (light: 0x1565C0, dark: 0x42A5F5))
    
    /// Info light background
    public static let infoLight = Color(adaptive: (light: 0xE3F2FD, dark: 0x0D2137))
    
    // MARK: - Text Colors (Adaptive)
    
    /// Primary text color - adapts to light/dark mode
    public static let textPrimary = Color(adaptive: (light: 0x1A1A1A, dark: 0xFFFFFF))
    
    /// Secondary text color - adapts to light/dark mode
    public static let textSecondary = Color(adaptive: (light: 0x4A4A4A, dark: 0xB0B0B0))
    
    /// Tertiary/placeholder text color - adapts to light/dark mode
    public static let textTertiary = Color(adaptive: (light: 0x8A8A8A, dark: 0x8A8A8A))
    
    /// Text color for use on dark/primary backgrounds
    public static let textOnPrimary = Color(hex: 0xFFFFFF)
    
    // MARK: - Background Colors (Adaptive)
    
    /// Default page/screen background - adapts to light/dark mode
    public static let backgroundPage = Color(adaptive: (light: 0xFFFFFF, dark: 0x000000))
    
    /// Card/surface background - adapts to light/dark mode
    public static let backgroundCard = Color(adaptive: (light: 0xF5F5F5, dark: 0x1C1C1E))
    
    /// Elevated surface background - adapts to light/dark mode
    public static let backgroundElevated = Color(adaptive: (light: 0xFFFFFF, dark: 0x2C2C2E))
    
    // MARK: - Divider/Border Colors (Adaptive)
    
    /// Divider color - adapts to light/dark mode
    public static let divider = Color(adaptive: (light: 0xE5E5E5, dark: 0x38383A))
}

// MARK: - Color Extension for Hex Values

public extension Color {
    /// Initialize a Color from a hex value
    /// - Parameter hex: The hex value (e.g., 0xFF6D00)
    init(hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0
        )
    }
    
    /// Initialize a Color from a hex value with alpha
    /// - Parameters:
    ///   - hex: The hex value (e.g., 0xFF6D00)
    ///   - alpha: The alpha value (0.0 - 1.0)
    init(hex: UInt, alpha: Double) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
    
    /// Initialize an adaptive Color that changes based on light/dark mode
    /// - Parameter adaptive: A tuple containing (light mode hex, dark mode hex)
    init(adaptive: (light: UInt, dark: UInt)) {
        #if canImport(UIKit)
        self.init(UIColor { traitCollection in
            let hex = traitCollection.userInterfaceStyle == .dark ? adaptive.dark : adaptive.light
            return UIColor(
                red: CGFloat((hex >> 16) & 0xFF) / 255.0,
                green: CGFloat((hex >> 8) & 0xFF) / 255.0,
                blue: CGFloat(hex & 0xFF) / 255.0,
                alpha: 1.0
            )
        })
        #else
        // Fallback to light mode for non-UIKit platforms
        self.init(hex: adaptive.light)
        #endif
    }
}

// MARK: - SwiftUI View Modifier Helpers

public extension View {
    /// Apply primary text color
    func primaryTextColor() -> some View {
        foregroundColor(DSColors.textPrimary)
    }
    
    /// Apply secondary text color
    func secondaryTextColor() -> some View {
        foregroundColor(DSColors.textSecondary)
    }
    
    /// Apply tertiary text color
    func tertiaryTextColor() -> some View {
        foregroundColor(DSColors.textTertiary)
    }
}
