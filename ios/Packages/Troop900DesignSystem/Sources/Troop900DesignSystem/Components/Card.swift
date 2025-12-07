import SwiftUI

// MARK: - Design System Cards
// Based on Troop 900 iOS UI Design Specification

/// Standard card component for containing related content.
/// Uses: Neutral 100 or Neutral 0 background, radius-md, shadow-md, spacing-md padding.
public struct DSCard<Content: View>: View {
    private let content: Content
    private let backgroundColor: Color
    private let hasShadow: Bool
    private let alignment: Alignment
    
    public init(
        backgroundColor: Color = DSColors.backgroundElevated,
        hasShadow: Bool = true,
        alignment: Alignment = .leading,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.backgroundColor = backgroundColor
        self.hasShadow = hasShadow
        self.alignment = alignment
    }
    
    public var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: alignment)
            .padding(DSSpacing.md)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
            .if(hasShadow) { view in
                view.shadowMd()
            }
    }
}

// MARK: - Section Card

/// A card with a section header and optional action.
public struct DSSectionCard<Content: View>: View {
    private let title: String
    private let actionTitle: String?
    private let action: (() -> Void)?
    private let content: Content
    
    public init(
        title: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.actionTitle = actionTitle
        self.action = action
        self.content = content()
    }
    
    public var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                HStack {
                    Text(title.uppercased())
                        .font(DSTypography.caption1)
                        .foregroundColor(DSColors.textTertiary)
                        .tracking(0.5)
                    
                    Spacer()
                    
                    if let actionTitle = actionTitle, let action = action {
                        DSTextButton(actionTitle, action: action)
                    }
                }
                
                content
            }
        }
    }
}

// MARK: - Info Card

/// An informational card with an icon and message.
/// Used for tips, notes, and contextual information.
public struct DSInfoCard: View {
    public enum Style {
        case info
        case warning
        case success
        case error
        
        var backgroundColor: Color {
            switch self {
            case .info: return DSColors.infoLight
            case .warning: return DSColors.warningLight
            case .success: return DSColors.successLight
            case .error: return DSColors.errorLight
            }
        }
        
        var iconColor: Color {
            switch self {
            case .info: return DSColors.info
            case .warning: return DSColors.warning
            case .success: return DSColors.success
            case .error: return DSColors.error
            }
        }
        
        var icon: DSIcon {
            switch self {
            case .info: return .infoFill
            case .warning: return .warning
            case .success: return .success
            case .error: return .critical
            }
        }
    }
    
    private let message: String
    private let style: Style
    
    public init(_ message: String, style: Style = .info) {
        self.message = message
        self.style = style
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            DSIconView(style.icon, size: .medium, color: style.iconColor)
            
            Text(message)
                .font(DSTypography.callout)
                .foregroundColor(DSColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DSSpacing.md)
        .background(style.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
    }
}

// MARK: - Alert Card

/// A prominent alert card for important messages.
/// Used for staffing alerts, warnings, etc.
public struct DSAlertCard: View {
    private let title: String
    private let message: String
    private let style: DSInfoCard.Style
    private let actionTitle: String?
    private let action: (() -> Void)?
    
    public init(
        title: String,
        message: String,
        style: DSInfoCard.Style = .warning,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.style = style
        self.actionTitle = actionTitle
        self.action = action
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack(spacing: DSSpacing.sm) {
                DSIconView(style.icon, size: .medium, color: style.iconColor)
                
                Text(title.uppercased())
                    .font(DSTypography.caption1)
                    .foregroundColor(style.iconColor)
                    .tracking(0.5)
                
                Spacer()
            }
            
            Text(message)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textPrimary)
            
            if let actionTitle = actionTitle, let action = action {
                HStack {
                    Spacer()
                    DSSecondaryButton(actionTitle, size: .compact, isFullWidth: false, action: action)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DSSpacing.md)
        .background(style.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
    }
}

// MARK: - Tappable Card Row

/// A card-style row that can be tapped to navigate.
/// Shows content with optional chevron indicator.
public struct DSTappableCardRow<Content: View>: View {
    private let content: Content
    private let showChevron: Bool
    private let action: () -> Void
    
    public init(
        showChevron: Bool = true,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.showChevron = showChevron
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.md) {
                content
                
                Spacer()
                
                if showChevron {
                    DSIconView(.chevronRight, size: .small, color: DSColors.textTertiary)
                }
            }
            .padding(DSSpacing.md)
            .background(DSColors.backgroundElevated)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
            .shadowMd()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - View Extension Helper

extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Previews

#if DEBUG
struct DSCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: DSSpacing.lg) {
                DSCard {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Text("Basic Card").dsHeadline()
                        Text("This is a basic card with default styling.").dsBody()
                    }
                }
                
                DSSectionCard(title: "Your Family's Shifts", actionTitle: "View All") {
                    Text("Content goes here").dsBody()
                }
                
                DSInfoCard("When you sign Alex up for a shift, it will be visible to both households.", style: .info)
                
                DSInfoCard("You're offline. Some features are unavailable.", style: .warning)
                
                DSAlertCard(
                    title: "Staffing Alerts",
                    message: "3 shifts critically understaffed this week",
                    style: .warning,
                    actionTitle: "View Alerts"
                ) { }
                
                DSTappableCardRow(action: { }) {
                    VStack(alignment: .leading) {
                        Text("Family Management").dsHeadline()
                        Text("Manage family members").dsCallout()
                    }
                }
            }
            .padding()
        }
        .background(DSColors.neutral100)
    }
}
#endif
