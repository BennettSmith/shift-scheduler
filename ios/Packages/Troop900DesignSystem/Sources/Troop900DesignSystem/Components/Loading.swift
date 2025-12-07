import SwiftUI

// MARK: - Design System Loading States
// Based on Troop 900 iOS UI Design Specification
// Uses native iOS activity indicators and skeleton loading for cards

/// A simple loading spinner with optional message.
public struct DSLoadingSpinner: View {
    private let message: String?
    private let color: Color
    
    public init(message: String? = nil, color: Color = DSColors.primary) {
        self.message = message
        self.color = color
    }
    
    public var body: some View {
        VStack(spacing: DSSpacing.md) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: color))
                .scaleEffect(1.2)
            
            if let message = message {
                Text(message)
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textSecondary)
            }
        }
    }
}

// MARK: - Full Screen Loading

/// A full-screen loading overlay.
public struct DSFullScreenLoading: View {
    private let message: String?
    
    public init(message: String? = "Loading...") {
        self.message = message
    }
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: DSSpacing.md) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                if let message = message {
                    Text(message)
                        .font(DSTypography.body)
                        .foregroundColor(.white)
                }
            }
            .padding(DSSpacing.xl)
            .background(Color.black.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
        }
    }
}

// MARK: - Skeleton Loading Views

/// A skeleton placeholder that shimmers while loading.
public struct DSSkeleton: View {
    private let width: CGFloat?
    private let height: CGFloat
    private let cornerRadius: CGFloat
    
    @State private var isAnimating = false
    
    public init(width: CGFloat? = nil, height: CGFloat = 20, cornerRadius: CGFloat = DSRadius.sm) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        DSColors.neutral200,
                        DSColors.neutral100,
                        DSColors.neutral200
                    ]),
                    startPoint: isAnimating ? .leading : .trailing,
                    endPoint: isAnimating ? .trailing : .leading
                )
            )
            .frame(width: width, height: height)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Skeleton Card

/// A skeleton placeholder for a card while loading.
public struct DSSkeletonCard: View {
    public init() {}
    
    public var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                DSSkeleton(width: 120, height: 12)
                DSSkeleton(height: 20)
                DSSkeleton(width: 200, height: 16)
            }
        }
    }
}

// MARK: - Skeleton Row

/// A skeleton placeholder for a list row.
public struct DSSkeletonRow: View {
    private let hasIcon: Bool
    private let hasChevron: Bool
    
    public init(hasIcon: Bool = true, hasChevron: Bool = true) {
        self.hasIcon = hasIcon
        self.hasChevron = hasChevron
    }
    
    public var body: some View {
        HStack(spacing: DSSpacing.md) {
            if hasIcon {
                DSSkeleton(width: 40, height: 40, cornerRadius: 20)
            }
            
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                DSSkeleton(width: 150, height: 18)
                DSSkeleton(width: 100, height: 14)
            }
            
            Spacer()
            
            if hasChevron {
                DSSkeleton(width: 12, height: 20)
            }
        }
        .padding(DSSpacing.md)
    }
}

// MARK: - Skeleton Shift Card

/// A skeleton placeholder specifically for shift cards.
public struct DSSkeletonShiftCard: View {
    public init() {}
    
    public var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                HStack {
                    DSSkeleton(width: 140, height: 18)
                    Spacer()
                    DSSkeleton(width: 20, height: 20, cornerRadius: 10)
                }
                DSSkeleton(width: 100, height: 16)
                
                HStack(spacing: DSSpacing.md) {
                    DSSkeleton(width: 80, height: 14)
                    DSSkeleton(width: 80, height: 14)
                    Spacer()
                    DSSkeleton(width: 90, height: 24, cornerRadius: DSRadius.full)
                }
            }
        }
    }
}

// MARK: - Skeleton Week Card

/// A skeleton placeholder for week overview cards.
public struct DSSkeletonWeekCard: View {
    public init() {}
    
    public var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                DSSkeleton(width: 80, height: 20)
                DSSkeleton(width: 120, height: 16)
                
                HStack(spacing: DSSpacing.md) {
                    DSSkeleton(width: 70, height: 14)
                    DSSkeleton(width: 100, height: 14)
                    DSSkeleton(width: 80, height: 14)
                }
            }
        }
    }
}

// MARK: - Skeleton Profile Header

/// A skeleton placeholder for the profile header.
public struct DSSkeletonProfileHeader: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: DSSpacing.sm) {
            DSSkeleton(width: 80, height: 80, cornerRadius: 40)
            DSSkeleton(width: 150, height: 24)
            DSSkeleton(width: 120, height: 16)
        }
    }
}

// MARK: - Loading View Modifier

/// A view modifier that shows a loading overlay when isLoading is true.
public struct DSLoadingModifier: ViewModifier {
    let isLoading: Bool
    let message: String?
    
    public func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isLoading)
            
            if isLoading {
                DSFullScreenLoading(message: message)
            }
        }
    }
}

public extension View {
    /// Show a loading overlay when isLoading is true.
    func loading(_ isLoading: Bool, message: String? = "Loading...") -> some View {
        modifier(DSLoadingModifier(isLoading: isLoading, message: message))
    }
}

// MARK: - Pull to Refresh Wrapper

/// A wrapper that adds pull-to-refresh functionality.
public struct DSRefreshableView<Content: View>: View {
    private let content: Content
    private let onRefresh: () async -> Void
    
    public init(
        onRefresh: @escaping () async -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.onRefresh = onRefresh
        self.content = content()
    }
    
    public var body: some View {
        ScrollView {
            content
        }
        .refreshable {
            await onRefresh()
        }
    }
}

// MARK: - Previews

#if DEBUG
struct DSLoading_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: DSSpacing.xl) {
                Group {
                    Text("Loading Spinner").dsHeadline()
                    DSLoadingSpinner()
                    DSLoadingSpinner(message: "Signing up...")
                }
                
                Divider()
                
                Group {
                    Text("Skeleton Cards").dsHeadline()
                    DSSkeletonCard()
                    DSSkeletonShiftCard()
                    DSSkeletonWeekCard()
                }
                
                Divider()
                
                Group {
                    Text("Skeleton Rows").dsHeadline()
                    DSSkeletonRow()
                    DSSkeletonRow(hasIcon: false)
                }
                
                Divider()
                
                Group {
                    Text("Profile Header Skeleton").dsHeadline()
                    DSSkeletonProfileHeader()
                }
            }
            .padding()
        }
    }
}
#endif
