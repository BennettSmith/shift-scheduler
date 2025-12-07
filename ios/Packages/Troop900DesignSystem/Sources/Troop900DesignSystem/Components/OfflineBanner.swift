import SwiftUI

// MARK: - Design System Offline Banner
// Based on Troop 900 iOS UI Design Specification
// Appears at top of screen when offline, warning yellow background, dismissible

/// Offline banner that appears when the device loses network connectivity.
public struct DSOfflineBanner: View {
    @Binding var isVisible: Bool
    private let message: String
    private let isDismissible: Bool
    
    public init(
        isVisible: Binding<Bool>,
        message: String = "You're offline. Some features are unavailable.",
        isDismissible: Bool = true
    ) {
        self._isVisible = isVisible
        self.message = message
        self.isDismissible = isDismissible
    }
    
    public var body: some View {
        if isVisible {
            HStack(spacing: DSSpacing.sm) {
                DSIconView(.warning, size: .medium, color: DSColors.warning)
                
                Text(message)
                    .font(DSTypography.callout)
                    .foregroundColor(DSColors.textPrimary)
                    .lineLimit(2)
                
                Spacer(minLength: 0)
                
                if isDismissible {
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) {
                            isVisible = false
                        }
                    } label: {
                        DSIconView(.close, size: .small, color: DSColors.textSecondary)
                    }
                }
            }
            .padding(DSSpacing.md)
            .background(DSColors.warningLight)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// MARK: - Offline Banner View Modifier

/// A view modifier that adds an offline banner at the top of any view.
public struct DSOfflineBannerModifier: ViewModifier {
    @Binding var isOffline: Bool
    @State private var isBannerVisible: Bool = true
    
    public func body(content: Content) -> some View {
        VStack(spacing: 0) {
            if isOffline && isBannerVisible {
                DSOfflineBanner(isVisible: $isBannerVisible)
            }
            
            content
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isOffline && isBannerVisible)
        .onChange(of: isOffline) { newValue in
            if newValue {
                // Show banner again when going offline
                isBannerVisible = true
            }
        }
    }
}

public extension View {
    /// Add offline banner support to a view.
    /// - Parameter isOffline: Binding to the offline state.
    func offlineBanner(isOffline: Binding<Bool>) -> some View {
        modifier(DSOfflineBannerModifier(isOffline: isOffline))
    }
}

// MARK: - Check-In Specific Offline Banner

/// A specialized offline banner for the Check-In tab.
public struct DSCheckInOfflineBanner: View {
    @Binding var isVisible: Bool
    
    public init(isVisible: Binding<Bool>) {
        self._isVisible = isVisible
    }
    
    public var body: some View {
        DSOfflineBanner(
            isVisible: $isVisible,
            message: "You're offline. Check-in/out unavailable."
        )
    }
}

// MARK: - Stale Data Indicator

/// Shows when data was last updated (for offline mode).
public struct DSStaleDataIndicator: View {
    private let lastUpdated: Date
    
    public init(lastUpdated: Date) {
        self.lastUpdated = lastUpdated
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: lastUpdated)
    }
    
    public var body: some View {
        Text("Last updated: \(formattedTime)")
            .font(DSTypography.caption2)
            .foregroundColor(DSColors.textTertiary)
    }
}

// MARK: - Disabled Action Indicator

/// Shows when an action is disabled due to offline state.
public struct DSOfflineDisabledView<Content: View>: View {
    private let isOffline: Bool
    private let content: Content
    
    public init(isOffline: Bool, @ViewBuilder content: () -> Content) {
        self.isOffline = isOffline
        self.content = content()
    }
    
    public var body: some View {
        VStack(spacing: DSSpacing.sm) {
            content
                .opacity(isOffline ? 0.5 : 1.0)
                .disabled(isOffline)
            
            if isOffline {
                HStack(spacing: DSSpacing.xs) {
                    DSIconView(.warning, size: .small, color: DSColors.warning)
                    Text("You're offline")
                        .font(DSTypography.caption1)
                        .foregroundColor(DSColors.textTertiary)
                }
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
struct DSOfflineBanner_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var isOffline = true
        
        var body: some View {
            VStack(spacing: 0) {
                DSOfflineBanner(isVisible: $isOffline)
                
                ScrollView {
                    VStack(spacing: DSSpacing.lg) {
                        Text("Offline Banner Preview").dsTitle2()
                        
                        Toggle("Simulate Offline", isOn: $isOffline)
                        
                        Divider()
                        
                        Text("Disabled Button Example").dsHeadline()
                        
                        DSOfflineDisabledView(isOffline: isOffline) {
                            DSPrimaryButton("Sign Up") { }
                        }
                        
                        Divider()
                        
                        Text("Stale Data Indicator").dsHeadline()
                        
                        HStack {
                            Text("STAFFING")
                                .font(DSTypography.caption1)
                                .foregroundColor(DSColors.textTertiary)
                            Spacer()
                            DSStaleDataIndicator(lastUpdated: Date().addingTimeInterval(-300))
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}
#endif
