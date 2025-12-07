import SwiftUI

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
    
    /// Primary light color (#FFF3E0)
    /// Use for backgrounds and highlights
    public static let primaryLight = Color(hex: 0xFFF3E0)
    
    // MARK: - Neutrals
    
    /// Neutral 900 (#1A1A1A)
    /// Primary text color
    public static let neutral900 = Color(hex: 0x1A1A1A)
    
    /// Neutral 700 (#4A4A4A)
    /// Secondary text color
    public static let neutral700 = Color(hex: 0x4A4A4A)
    
    /// Neutral 500 (#8A8A8A)
    /// Tertiary text, placeholders
    public static let neutral500 = Color(hex: 0x8A8A8A)
    
    /// Neutral 300 (#B0B0B0)
    /// Disabled states, subtle elements
    public static let neutral300 = Color(hex: 0xB0B0B0)
    
    /// Neutral 200 (#E5E5E5)
    /// Borders, dividers
    public static let neutral200 = Color(hex: 0xE5E5E5)
    
    /// Neutral 100 (#F5F5F5)
    /// Card backgrounds
    public static let neutral100 = Color(hex: 0xF5F5F5)
    
    /// Neutral 0 / White (#FFFFFF)
    /// Page backgrounds
    public static let neutral0 = Color(hex: 0xFFFFFF)
    
    // MARK: - Semantic Colors
    
    /// Success color (#2E7D32)
    /// Checked in, confirmed, fully staffed
    public static let success = Color(hex: 0x2E7D32)
    
    /// Success light background
    public static let successLight = Color(hex: 0xE8F5E9)
    
    /// Warning color (#F9A825)
    /// Needs attention, understaffed
    public static let warning = Color(hex: 0xF9A825)
    
    /// Warning light background
    public static let warningLight = Color(hex: 0xFFF8E1)
    
    /// Error color (#C62828)
    /// Critical, errors, cancellations
    public static let error = Color(hex: 0xC62828)
    
    /// Error light background
    public static let errorLight = Color(hex: 0xFFEBEE)
    
    /// Info color (#1565C0)
    /// Informational states
    public static let info = Color(hex: 0x1565C0)
    
    /// Info light background
    public static let infoLight = Color(hex: 0xE3F2FD)
    
    // MARK: - Text Colors
    
    /// Primary text color (use on light backgrounds)
    public static let textPrimary = neutral900
    
    /// Secondary text color
    public static let textSecondary = neutral700
    
    /// Tertiary/placeholder text color
    public static let textTertiary = neutral500
    
    /// Text color for use on dark/primary backgrounds
    public static let textOnPrimary = neutral0
    
    // MARK: - Background Colors
    
    /// Default page/screen background
    public static let backgroundPage = neutral0
    
    /// Card/surface background
    public static let backgroundCard = neutral100
    
    /// Elevated surface background (white cards on gray background)
    public static let backgroundElevated = neutral0
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
