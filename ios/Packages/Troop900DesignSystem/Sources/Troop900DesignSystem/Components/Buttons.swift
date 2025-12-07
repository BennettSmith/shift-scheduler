import SwiftUI

// MARK: - Design System Buttons
// Based on Troop 900 iOS UI Design Specification

/// Button style configuration
public enum DSButtonStyle {
    case primary
    case secondary
    case destructive
    case destructiveSecondary
}

/// Button size configuration
public enum DSButtonSize {
    case regular    // Height: 50pt
    case small      // Height: 40pt
    case compact    // Height: 36pt
    
    var height: CGFloat {
        switch self {
        case .regular: return 50
        case .small: return 40
        case .compact: return 36
        }
    }
    
    var font: Font {
        switch self {
        case .regular: return DSTypography.button
        case .small, .compact: return DSTypography.buttonSmall
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .regular: return DSSpacing.lg
        case .small: return DSSpacing.md
        case .compact: return DSSpacing.sm
        }
    }
}

// MARK: - Primary Button

/// Primary action button with orange background and white text.
/// Use for main actions like "Sign Up", "Confirm", "Save".
public struct DSPrimaryButton: View {
    private let title: String
    private let icon: DSIcon?
    private let size: DSButtonSize
    private let isFullWidth: Bool
    private let isLoading: Bool
    private let isDisabled: Bool
    private let action: () -> Void
    
    public init(
        _ title: String,
        icon: DSIcon? = nil,
        size: DSButtonSize = .regular,
        isFullWidth: Bool = true,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.size = size
        self.isFullWidth = isFullWidth
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: DSColors.textOnPrimary))
                } else {
                    if let icon = icon {
                        Image(systemName: icon.rawValue)
                    }
                    Text(title)
                }
            }
            .font(size.font)
            .foregroundColor(DSColors.textOnPrimary)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .background(isDisabled ? DSColors.neutral300 : DSColors.primary)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
        }
        .disabled(isDisabled || isLoading)
    }
}

// MARK: - Secondary Button

/// Secondary action button with transparent background and orange border/text.
/// Use for alternative actions like "Cancel", "Back", "Learn More".
public struct DSSecondaryButton: View {
    private let title: String
    private let icon: DSIcon?
    private let size: DSButtonSize
    private let isFullWidth: Bool
    private let isLoading: Bool
    private let isDisabled: Bool
    private let action: () -> Void
    
    public init(
        _ title: String,
        icon: DSIcon? = nil,
        size: DSButtonSize = .regular,
        isFullWidth: Bool = true,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.size = size
        self.isFullWidth = isFullWidth
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: DSColors.primary))
                } else {
                    if let icon = icon {
                        Image(systemName: icon.rawValue)
                    }
                    Text(title)
                }
            }
            .font(size.font)
            .foregroundColor(isDisabled ? DSColors.neutral300 : DSColors.primary)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.sm)
                    .stroke(isDisabled ? DSColors.neutral300 : DSColors.primary, lineWidth: 1)
            )
        }
        .disabled(isDisabled || isLoading)
    }
}

// MARK: - Destructive Button

/// Destructive action button with red text, no background.
/// Use for dangerous actions like "Delete", "Sign Out", "Cancel Signup".
public struct DSDestructiveButton: View {
    private let title: String
    private let icon: DSIcon?
    private let size: DSButtonSize
    private let isFullWidth: Bool
    private let isLoading: Bool
    private let isDisabled: Bool
    private let action: () -> Void
    
    public init(
        _ title: String,
        icon: DSIcon? = nil,
        size: DSButtonSize = .regular,
        isFullWidth: Bool = false,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.size = size
        self.isFullWidth = isFullWidth
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: DSColors.error))
                } else {
                    if let icon = icon {
                        Image(systemName: icon.rawValue)
                    }
                    Text(title)
                }
            }
            .font(size.font)
            .foregroundColor(isDisabled ? DSColors.neutral300 : DSColors.error)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
        }
        .disabled(isDisabled || isLoading)
    }
}

// MARK: - Text Button

/// Simple text button for inline actions.
/// Renders as clickable text with primary color.
public struct DSTextButton: View {
    private let title: String
    private let icon: DSIcon?
    private let color: Color
    private let action: () -> Void
    
    public init(
        _ title: String,
        icon: DSIcon? = nil,
        color: Color = DSColors.primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.xs) {
                if let icon = icon {
                    Image(systemName: icon.rawValue)
                }
                Text(title)
            }
            .font(DSTypography.body)
            .foregroundColor(color)
        }
    }
}

// MARK: - Icon Button

/// A button containing only an icon.
/// Use for toolbar actions, close buttons, etc.
public struct DSIconButton: View {
    private let icon: DSIcon
    private let size: DSIconView.IconSize
    private let color: Color
    private let action: () -> Void
    
    public init(
        icon: DSIcon,
        size: DSIconView.IconSize = .large,
        color: Color = DSColors.primary,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.color = color
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            DSIconView(icon, size: size, color: color)
                .frame(width: 44, height: 44) // Minimum touch target
                .contentShape(Rectangle())
        }
    }
}

// MARK: - Check In/Out Button

/// Specialized button for check-in/check-out actions.
public struct DSCheckInButton: View {
    public enum Mode {
        case checkIn
        case checkOut
    }
    
    private let mode: Mode
    private let isLoading: Bool
    private let action: () -> Void
    
    public init(
        mode: Mode,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.mode = mode
        self.isLoading = isLoading
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: mode == .checkIn ? DSColors.textOnPrimary : DSColors.primary))
                } else {
                    Image(systemName: mode == .checkIn ? "checkmark" : "arrow.right.square")
                    Text(mode == .checkIn ? "Check In" : "Check Out")
                }
            }
            .font(DSTypography.buttonSmall)
            .foregroundColor(mode == .checkIn ? DSColors.textOnPrimary : DSColors.primary)
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)
            .background(mode == .checkIn ? DSColors.primary : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.sm)
                    .stroke(DSColors.primary, lineWidth: mode == .checkOut ? 1 : 0)
            )
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
        }
        .disabled(isLoading)
    }
}

// MARK: - Previews

#if DEBUG
struct DSButtons_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: DSSpacing.lg) {
                Group {
                    Text("Primary Buttons").dsHeadline()
                    DSPrimaryButton("Sign Up") { }
                    DSPrimaryButton("Confirm Sign Up", icon: .success) { }
                    DSPrimaryButton("Loading", isLoading: true) { }
                    DSPrimaryButton("Disabled", isDisabled: true) { }
                }
                
                Divider()
                
                Group {
                    Text("Secondary Buttons").dsHeadline()
                    DSSecondaryButton("Cancel") { }
                    DSSecondaryButton("View Schedule", icon: .calendar) { }
                    DSSecondaryButton("Disabled", isDisabled: true) { }
                }
                
                Divider()
                
                Group {
                    Text("Destructive Buttons").dsHeadline()
                    DSDestructiveButton("Cancel Signup") { }
                    DSDestructiveButton("Sign Out", icon: .signOut) { }
                }
                
                Divider()
                
                Group {
                    Text("Text Buttons").dsHeadline()
                    DSTextButton("Find a shift →") { }
                    DSTextButton("View Details", icon: .chevronRight) { }
                }
                
                Divider()
                
                Group {
                    Text("Check In/Out Buttons").dsHeadline()
                    HStack {
                        DSCheckInButton(mode: .checkIn) { }
                        DSCheckInButton(mode: .checkOut) { }
                    }
                }
            }
            .padding()
        }
    }
}
#endif
