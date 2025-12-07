import SwiftUI

// MARK: - Design System Colors
// Based on Troop 900 iOS UI Design Specification
// Adaptive colors use Asset Catalog for proper light/dark mode transitions

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
    
    /// Primary light color - adapts for dark mode
    /// Use for backgrounds and highlights
    public static let primaryLight = Color("PrimaryLight", bundle: .module)
    
    // MARK: - Neutrals
    
    /// Neutral 900 (#1A1A1A)
    public static let neutral900 = Color(hex: 0x1A1A1A)
    
    /// Neutral 700 (#4A4A4A)
    public static let neutral700 = Color(hex: 0x4A4A4A)
    
    /// Neutral 500 (#8A8A8A)
    public static let neutral500 = Color(hex: 0x8A8A8A)
    
    /// Neutral 300 (#B0B0B0)
    public static let neutral300 = Color(hex: 0xB0B0B0)
    
    /// Neutral 200 - adapts for dark mode
    public static let neutral200 = Color("Neutral200", bundle: .module)
    
    /// Neutral 100 - adapts for dark mode
    public static let neutral100 = Color("Neutral100", bundle: .module)
    
    /// Neutral 0 / White (#FFFFFF)
    public static let neutral0 = Color(hex: 0xFFFFFF)
    
    // MARK: - Semantic Colors
    
    /// Success color - adapts for dark mode (brighter in dark)
    /// Checked in, confirmed, fully staffed
    public static let success = Color("Success", bundle: .module)
    
    /// Success light background - adapts for dark mode
    public static let successLight = Color("SuccessLight", bundle: .module)
    
    /// Warning color (#F9A825)
    /// Needs attention, understaffed
    public static let warning = Color(hex: 0xF9A825)
    
    /// Warning light background - adapts for dark mode
    public static let warningLight = Color("WarningLight", bundle: .module)
    
    /// Error color - adapts for dark mode (brighter in dark)
    /// Critical, errors, cancellations
    public static let error = Color("Error", bundle: .module)
    
    /// Error light background - adapts for dark mode
    public static let errorLight = Color("ErrorLight", bundle: .module)
    
    /// Info color - adapts for dark mode (brighter in dark)
    /// Informational states
    public static let info = Color("Info", bundle: .module)
    
    /// Info light background - adapts for dark mode
    public static let infoLight = Color("InfoLight", bundle: .module)
    
    // MARK: - Text Colors (Adaptive)
    
    /// Primary text color - adapts to light/dark mode
    public static let textPrimary = Color("TextPrimary", bundle: .module)
    
    /// Secondary text color - adapts to light/dark mode
    public static let textSecondary = Color("TextSecondary", bundle: .module)
    
    /// Tertiary/placeholder text color - adapts to light/dark mode
    public static let textTertiary = Color("TextTertiary", bundle: .module)
    
    /// Text color for use on dark/primary backgrounds
    public static let textOnPrimary = Color(hex: 0xFFFFFF)
    
    // MARK: - Background Colors (Adaptive)
    
    /// Default page/screen background - adapts to light/dark mode
    public static let backgroundPage = Color("BackgroundPage", bundle: .module)
    
    /// Card/surface background - adapts to light/dark mode
    public static let backgroundCard = Color("BackgroundCard", bundle: .module)
    
    /// Elevated surface background - adapts to light/dark mode
    public static let backgroundElevated = Color("BackgroundElevated", bundle: .module)
    
    // MARK: - Divider/Border Colors (Adaptive)
    
    /// Divider color - adapts to light/dark mode
    public static let divider = Color("Divider", bundle: .module)
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
