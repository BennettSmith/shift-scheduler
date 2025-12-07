import SwiftUI

// MARK: - Design System Typography
// Based on Troop 900 iOS UI Design Specification
// Uses San Francisco (iOS system font) throughout

/// Typography styles for the Troop 900 Tree Lot app.
public enum DSTypography {
    
    // MARK: - Font Styles
    
    /// Large Title - Bold 34pt, Line height 41pt
    /// Use for screen titles
    public static let largeTitle = Font.system(size: 34, weight: .bold)
    
    /// Title 1 - Bold 28pt, Line height 34pt
    /// Use for section headers
    public static let title1 = Font.system(size: 28, weight: .bold)
    
    /// Title 2 - Bold 22pt, Line height 28pt
    /// Use for card titles
    public static let title2 = Font.system(size: 22, weight: .bold)
    
    /// Title 3 - Semibold 20pt, Line height 25pt
    /// Use for subsection headers
    public static let title3 = Font.system(size: 20, weight: .semibold)
    
    /// Headline - Semibold 17pt, Line height 22pt
    /// Use for list item titles
    public static let headline = Font.system(size: 17, weight: .semibold)
    
    /// Body - Regular 17pt, Line height 22pt
    /// Use for primary content
    public static let body = Font.system(size: 17, weight: .regular)
    
    /// Callout - Regular 16pt, Line height 21pt
    /// Use for supporting content
    public static let callout = Font.system(size: 16, weight: .regular)
    
    /// Subhead - Regular 15pt, Line height 20pt
    /// Use for secondary labels
    public static let subhead = Font.system(size: 15, weight: .regular)
    
    /// Footnote - Regular 13pt, Line height 18pt
    /// Use for tertiary information
    public static let footnote = Font.system(size: 13, weight: .regular)
    
    /// Caption 1 - Regular 12pt, Line height 16pt
    /// Use for timestamps, metadata
    public static let caption1 = Font.system(size: 12, weight: .regular)
    
    /// Caption 2 - Regular 11pt, Line height 13pt
    /// Use for badges, small labels
    public static let caption2 = Font.system(size: 11, weight: .regular)
    
    // MARK: - Button Typography
    
    /// Button text - Semibold 17pt
    public static let button = Font.system(size: 17, weight: .semibold)
    
    /// Small button text - Semibold 15pt
    public static let buttonSmall = Font.system(size: 15, weight: .semibold)
}

// MARK: - Text Style View Modifier

/// A view modifier that applies typography styles with proper color
public struct DSTextStyle: ViewModifier {
    let font: Font
    let color: Color
    
    public init(font: Font, color: Color = DSColors.textPrimary) {
        self.font = font
        self.color = color
    }
    
    public func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(color)
    }
}

// MARK: - View Extensions for Typography

public extension View {
    /// Apply Large Title style
    func largeTitleStyle(color: Color = DSColors.textPrimary) -> some View {
        modifier(DSTextStyle(font: DSTypography.largeTitle, color: color))
    }
    
    /// Apply Title 1 style
    func title1Style(color: Color = DSColors.textPrimary) -> some View {
        modifier(DSTextStyle(font: DSTypography.title1, color: color))
    }
    
    /// Apply Title 2 style
    func title2Style(color: Color = DSColors.textPrimary) -> some View {
        modifier(DSTextStyle(font: DSTypography.title2, color: color))
    }
    
    /// Apply Title 3 style
    func title3Style(color: Color = DSColors.textPrimary) -> some View {
        modifier(DSTextStyle(font: DSTypography.title3, color: color))
    }
    
    /// Apply Headline style
    func headlineStyle(color: Color = DSColors.textPrimary) -> some View {
        modifier(DSTextStyle(font: DSTypography.headline, color: color))
    }
    
    /// Apply Body style
    func bodyStyle(color: Color = DSColors.textPrimary) -> some View {
        modifier(DSTextStyle(font: DSTypography.body, color: color))
    }
    
    /// Apply Callout style
    func calloutStyle(color: Color = DSColors.textSecondary) -> some View {
        modifier(DSTextStyle(font: DSTypography.callout, color: color))
    }
    
    /// Apply Subhead style
    func subheadStyle(color: Color = DSColors.textSecondary) -> some View {
        modifier(DSTextStyle(font: DSTypography.subhead, color: color))
    }
    
    /// Apply Footnote style
    func footnoteStyle(color: Color = DSColors.textTertiary) -> some View {
        modifier(DSTextStyle(font: DSTypography.footnote, color: color))
    }
    
    /// Apply Caption 1 style
    func caption1Style(color: Color = DSColors.textTertiary) -> some View {
        modifier(DSTextStyle(font: DSTypography.caption1, color: color))
    }
    
    /// Apply Caption 2 style
    func caption2Style(color: Color = DSColors.textTertiary) -> some View {
        modifier(DSTextStyle(font: DSTypography.caption2, color: color))
    }
}

// MARK: - Text Convenience Extensions

public extension Text {
    /// Apply Large Title styling
    func dsLargeTitle() -> Text {
        self.font(DSTypography.largeTitle)
            .foregroundColor(DSColors.textPrimary)
    }
    
    /// Apply Title 1 styling
    func dsTitle1() -> Text {
        self.font(DSTypography.title1)
            .foregroundColor(DSColors.textPrimary)
    }
    
    /// Apply Title 2 styling
    func dsTitle2() -> Text {
        self.font(DSTypography.title2)
            .foregroundColor(DSColors.textPrimary)
    }
    
    /// Apply Title 3 styling
    func dsTitle3() -> Text {
        self.font(DSTypography.title3)
            .foregroundColor(DSColors.textPrimary)
    }
    
    /// Apply Headline styling
    func dsHeadline() -> Text {
        self.font(DSTypography.headline)
            .foregroundColor(DSColors.textPrimary)
    }
    
    /// Apply Body styling
    func dsBody() -> Text {
        self.font(DSTypography.body)
            .foregroundColor(DSColors.textPrimary)
    }
    
    /// Apply Callout styling
    func dsCallout() -> Text {
        self.font(DSTypography.callout)
            .foregroundColor(DSColors.textSecondary)
    }
    
    /// Apply Subhead styling
    func dsSubhead() -> Text {
        self.font(DSTypography.subhead)
            .foregroundColor(DSColors.textSecondary)
    }
    
    /// Apply Footnote styling
    func dsFootnote() -> Text {
        self.font(DSTypography.footnote)
            .foregroundColor(DSColors.textTertiary)
    }
    
    /// Apply Caption 1 styling
    func dsCaption1() -> Text {
        self.font(DSTypography.caption1)
            .foregroundColor(DSColors.textTertiary)
    }
    
    /// Apply Caption 2 styling
    func dsCaption2() -> Text {
        self.font(DSTypography.caption2)
            .foregroundColor(DSColors.textTertiary)
    }
}
