import SwiftUI

// MARK: - Design System Sheet Components
// Based on Troop 900 iOS UI Design Specification

/// A standard sheet header with title and close button.
public struct DSSheetHeader: View {
    private let title: String
    private let onClose: () -> Void
    
    public init(title: String, onClose: @escaping () -> Void) {
        self.title = title
        self.onClose = onClose
    }
    
    public var body: some View {
        HStack {
            Spacer()
            
            Text(title)
                .font(DSTypography.headline)
                .foregroundColor(DSColors.textPrimary)
            
            Spacer()
        }
        .overlay(alignment: .trailing) {
            DSIconButton(icon: .close, size: .medium, color: DSColors.textSecondary, action: onClose)
        }
        .padding(DSSpacing.md)
    }
}

// MARK: - Sheet Container

/// A container for sheet content with proper styling.
public struct DSSheet<Content: View>: View {
    private let title: String
    private let onClose: () -> Void
    private let content: Content
    
    public init(
        title: String,
        onClose: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.onClose = onClose
        self.content = content()
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            DSSheetHeader(title: title, onClose: onClose)
            
            DSDivider()
            
            ScrollView {
                content
                    .padding(DSSpacing.md)
            }
        }
    }
}

// MARK: - Action Sheet Button

/// A button style for action sheets.
public struct DSActionSheetButton: View {
    public enum Style {
        case `default`
        case destructive
        case cancel
    }
    
    private let title: String
    private let icon: DSIcon?
    private let style: Style
    private let action: () -> Void
    
    public init(
        _ title: String,
        icon: DSIcon? = nil,
        style: Style = .default,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    private var foregroundColor: Color {
        switch style {
        case .default: return DSColors.textPrimary
        case .destructive: return DSColors.error
        case .cancel: return DSColors.textTertiary
        }
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.md) {
                if let icon = icon {
                    DSIconView(icon, size: .medium, color: foregroundColor)
                }
                
                Text(title)
                    .font(style == .cancel ? DSTypography.body : DSTypography.headline)
                    .foregroundColor(foregroundColor)
                
                Spacer()
            }
            .padding(DSSpacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Confirmation Dialog

/// A styled confirmation dialog.
public struct DSConfirmationDialog: View {
    private let title: String
    private let message: String
    private let confirmTitle: String
    private let cancelTitle: String
    private let isDestructive: Bool
    private let onConfirm: () -> Void
    private let onCancel: () -> Void
    
    public init(
        title: String,
        message: String,
        confirmTitle: String = "Confirm",
        cancelTitle: String = "Cancel",
        isDestructive: Bool = false,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.confirmTitle = confirmTitle
        self.cancelTitle = cancelTitle
        self.isDestructive = isDestructive
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }
    
    public var body: some View {
        VStack(spacing: DSSpacing.lg) {
            VStack(spacing: DSSpacing.sm) {
                Text(title)
                    .font(DSTypography.headline)
                    .foregroundColor(DSColors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(message)
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            HStack(spacing: DSSpacing.md) {
                DSSecondaryButton(cancelTitle, action: onCancel)
                
                if isDestructive {
                    Button(action: onConfirm) {
                        Text(confirmTitle)
                            .font(DSTypography.button)
                            .foregroundColor(DSColors.textOnPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(DSColors.error)
                            .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
                    }
                } else {
                    DSPrimaryButton(confirmTitle, action: onConfirm)
                }
            }
        }
        .padding(DSSpacing.lg)
        .background(DSColors.backgroundElevated)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
        .shadowLg()
        .padding(DSSpacing.xl)
    }
}

// MARK: - Bottom Sheet Handle

/// A drag indicator handle for bottom sheets.
public struct DSBottomSheetHandle: View {
    public init() {}
    
    public var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(DSColors.neutral300)
            .frame(width: 36, height: 5)
            .padding(.top, DSSpacing.sm)
            .padding(.bottom, DSSpacing.xs)
    }
}

// MARK: - Sign Up Sheet Summary

/// A summary header for the sign-up sheet.
public struct DSShiftSummary: View {
    private let shiftName: String
    private let date: String
    private let time: String
    
    public init(shiftName: String, date: String, time: String) {
        self.shiftName = shiftName
        self.date = date
        self.time = time
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(shiftName)
                .font(DSTypography.title3)
                .foregroundColor(DSColors.textPrimary)
            
            Text("\(date), \(time)")
                .font(DSTypography.body)
                .foregroundColor(DSColors.textSecondary)
        }
    }
}

// MARK: - Success Sheet

/// A success confirmation sheet.
public struct DSSuccessSheet: View {
    private let title: String
    private let message: String
    private let bulletPoints: [String]
    private let buttonTitle: String
    private let onDismiss: () -> Void
    
    public init(
        title: String,
        message: String,
        bulletPoints: [String] = [],
        buttonTitle: String = "Done",
        onDismiss: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.bulletPoints = bulletPoints
        self.buttonTitle = buttonTitle
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        VStack(spacing: DSSpacing.lg) {
            DSIconView(.success, size: .custom(64), color: DSColors.success)
            
            Text(title)
                .font(DSTypography.title2)
                .foregroundColor(DSColors.textPrimary)
                .multilineTextAlignment(.center)
            
            Text(message)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textSecondary)
                .multilineTextAlignment(.center)
            
            if !bulletPoints.isEmpty {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    ForEach(bulletPoints, id: \.self) { point in
                        HStack(alignment: .top, spacing: DSSpacing.sm) {
                            Text("•")
                                .foregroundColor(DSColors.textSecondary)
                            Text(point)
                                .font(DSTypography.body)
                                .foregroundColor(DSColors.textSecondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(DSSpacing.md)
                .background(DSColors.neutral100)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
            }
            
            DSPrimaryButton(buttonTitle, action: onDismiss)
        }
        .padding(DSSpacing.lg)
    }
}

// MARK: - Previews

#if DEBUG
struct DSSheetComponents_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: DSSpacing.xl) {
            // Sheet Header
            DSSheetHeader(title: "Sign Up for Shift") { }
            
            // Shift Summary
            DSShiftSummary(
                shiftName: "Saturday Morning",
                date: "Nov 30",
                time: "9:00 AM - 1:00 PM"
            )
            .padding()
            
            // Confirmation Dialog
            DSConfirmationDialog(
                title: "Cancel Signup?",
                message: "Are you sure you want to cancel your signup for this shift?",
                confirmTitle: "Cancel Signup",
                isDestructive: true,
                onConfirm: { },
                onCancel: { }
            )
            
            Spacer()
        }
        .padding()
        
        // Success Sheet Preview
        DSSuccessSheet(
            title: "Scout Linked!",
            message: "Alex Smith has been added to your household.",
            bulletPoints: [
                "See all of Alex's shift assignments",
                "Sign Alex up for new shifts",
                "Check Alex in/out when you're working"
            ]
        ) { }
    }
}
#endif
