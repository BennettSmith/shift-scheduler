import SwiftUI

// MARK: - Design System Spacing
// Based on Troop 900 iOS UI Design Specification

/// Spacing scale for consistent layouts throughout the app.
public enum DSSpacing {
    /// Extra small spacing - 4pt
    /// Use for tight spacing, inline elements
    public static let xs: CGFloat = 4
    
    /// Small spacing - 8pt
    /// Use for related elements
    public static let sm: CGFloat = 8
    
    /// Medium spacing - 16pt
    /// Use for standard padding, gaps
    public static let md: CGFloat = 16
    
    /// Large spacing - 24pt
    /// Use for section spacing
    public static let lg: CGFloat = 24
    
    /// Extra large spacing - 32pt
    /// Use for major sections
    public static let xl: CGFloat = 32
    
    /// 2X large spacing - 48pt
    /// Use for screen-level spacing
    public static let xxl: CGFloat = 48
}

// MARK: - Design System Corner Radius

/// Corner radius values for consistent rounded corners.
public enum DSRadius {
    /// Small radius - 8pt
    /// Use for buttons, small elements
    public static let sm: CGFloat = 8
    
    /// Medium radius - 12pt
    /// Use for cards, inputs
    public static let md: CGFloat = 12
    
    /// Large radius - 16pt
    /// Use for modal sheets, large cards
    public static let lg: CGFloat = 16
    
    /// Full radius (pill shape) - 9999pt
    /// Use for pills, avatars
    public static let full: CGFloat = 9999
}

// MARK: - Design System Shadows

/// Shadow definitions for elevation and depth.
public enum DSShadow {
    /// Small shadow - subtle lift
    /// 0 1pt 2pt rgba(0,0,0,0.05)
    public static let sm = Shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    
    /// Medium shadow - cards
    /// 0 2pt 8pt rgba(0,0,0,0.10)
    public static let md = Shadow(color: .black.opacity(0.10), radius: 8, x: 0, y: 2)
    
    /// Large shadow - floating elements
    /// 0 4pt 16pt rgba(0,0,0,0.15)
    public static let lg = Shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 4)
}

/// Shadow configuration struct
public struct Shadow {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat
    
    public init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}

// MARK: - View Modifiers for Spacing

public extension View {
    /// Apply standard card padding (medium spacing)
    func cardPadding() -> some View {
        padding(DSSpacing.md)
    }
    
    /// Apply section spacing (large spacing)
    func sectionSpacing() -> some View {
        padding(.vertical, DSSpacing.lg)
    }
    
    /// Apply screen-level horizontal padding (medium spacing)
    func screenPadding() -> some View {
        padding(.horizontal, DSSpacing.md)
    }
}

// MARK: - View Modifiers for Shadows

public extension View {
    /// Apply small shadow
    func shadowSm() -> some View {
        shadow(color: DSShadow.sm.color, radius: DSShadow.sm.radius, x: DSShadow.sm.x, y: DSShadow.sm.y)
    }
    
    /// Apply medium shadow (card shadow)
    func shadowMd() -> some View {
        shadow(color: DSShadow.md.color, radius: DSShadow.md.radius, x: DSShadow.md.x, y: DSShadow.md.y)
    }
    
    /// Apply large shadow (floating elements)
    func shadowLg() -> some View {
        shadow(color: DSShadow.lg.color, radius: DSShadow.lg.radius, x: DSShadow.lg.x, y: DSShadow.lg.y)
    }
}

// MARK: - View Modifiers for Corner Radius

public extension View {
    /// Apply small corner radius
    func cornerRadiusSm() -> some View {
        clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
    }
    
    /// Apply medium corner radius
    func cornerRadiusMd() -> some View {
        clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
    }
    
    /// Apply large corner radius
    func cornerRadiusLg() -> some View {
        clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
    }
    
    /// Apply pill shape (full corner radius)
    func cornerRadiusFull() -> some View {
        clipShape(Capsule())
    }
}
