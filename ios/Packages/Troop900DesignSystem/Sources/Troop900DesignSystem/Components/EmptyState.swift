import SwiftUI

// MARK: - Design System Empty States
// Based on Troop 900 iOS UI Design Specification

/// A consistent empty state view for when there's no content to display.
/// Includes: large icon (48pt), primary message, secondary message, optional action button.
public struct DSEmptyState: View {
    private let icon: DSIcon
    private let title: String
    private let message: String
    private let actionTitle: String?
    private let action: (() -> Void)?
    
    public init(
        icon: DSIcon,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: DSSpacing.md) {
            DSIconView(icon, size: .xxlarge, color: DSColors.neutral300)
            
            Text(title)
                .font(DSTypography.title3)
                .foregroundColor(DSColors.textSecondary)
                .multilineTextAlignment(.center)
            
            Text(message)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textTertiary)
                .multilineTextAlignment(.center)
            
            if let actionTitle = actionTitle, let action = action {
                DSSecondaryButton(actionTitle, isFullWidth: false, action: action)
                    .padding(.top, DSSpacing.sm)
            }
        }
        .padding(DSSpacing.xl)
    }
}

// MARK: - Preset Empty States

public extension DSEmptyState {
    /// Empty state for no shifts today
    static func noShiftsToday(onViewSchedule: @escaping () -> Void) -> DSEmptyState {
        DSEmptyState(
            icon: .calendar,
            title: "No shifts today—enjoy your day! 🌲",
            message: "Check the schedule for upcoming shifts",
            actionTitle: "View Schedule",
            action: onViewSchedule
        )
    }
    
    /// Empty state for no upcoming shifts
    static func noUpcomingShifts(onFindShift: @escaping () -> Void) -> DSEmptyState {
        DSEmptyState(
            icon: .calendar,
            title: "No upcoming shifts",
            message: "Sign up for a shift to get started",
            actionTitle: "Find a shift →",
            action: onFindShift
        )
    }
    
    /// Empty state for check-in when lot is closed
    static func lotClosed(nextOpenInfo: String, onViewSchedule: @escaping () -> Void) -> DSEmptyState {
        DSEmptyState(
            icon: .calendar,
            title: "No shifts scheduled today",
            message: nextOpenInfo,
            actionTitle: "View Schedule",
            action: onViewSchedule
        )
    }
    
    /// Empty state for search with no results
    static func noSearchResults(searchTerm: String) -> DSEmptyState {
        DSEmptyState(
            icon: .search,
            title: "No results found",
            message: "Try a different search term"
        )
    }
    
    /// Empty state for network error
    static func networkError(onRetry: @escaping () -> Void) -> DSEmptyState {
        DSEmptyState(
            icon: .offline,
            title: "Couldn't connect",
            message: "Check your connection and try again.",
            actionTitle: "Try Again",
            action: onRetry
        )
    }
    
    /// Empty state for server error
    static func serverError(onRetry: @escaping () -> Void) -> DSEmptyState {
        DSEmptyState(
            icon: .warning,
            title: "Something went wrong",
            message: "Please try again later.",
            actionTitle: "Try Again",
            action: onRetry
        )
    }
}

// MARK: - Inline Empty State

/// A smaller inline empty state for use within cards or sections.
public struct DSInlineEmptyState: View {
    private let message: String
    private let actionTitle: String?
    private let action: (() -> Void)?
    
    public init(
        _ message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: DSSpacing.sm) {
            Text(message)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textTertiary)
                .multilineTextAlignment(.center)
            
            if let actionTitle = actionTitle, let action = action {
                DSTextButton(actionTitle, action: action)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DSSpacing.md)
    }
}

// MARK: - Previews

#if DEBUG
struct DSEmptyState_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: DSSpacing.xl) {
                DSEmptyState.noShiftsToday { }
                
                Divider()
                
                DSEmptyState.noUpcomingShifts { }
                
                Divider()
                
                DSEmptyState.lotClosed(nextOpenInfo: "The lot opens again tomorrow at 10 AM") { }
                
                Divider()
                
                DSEmptyState.networkError { }
                
                Divider()
                
                DSCard {
                    DSInlineEmptyState("No shifts scheduled", actionTitle: "Find a shift →") { }
                }
            }
            .padding()
        }
    }
}
#endif
