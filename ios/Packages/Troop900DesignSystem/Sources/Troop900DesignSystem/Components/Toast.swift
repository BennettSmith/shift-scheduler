import SwiftUI

// MARK: - Design System Toast Notifications
// Based on Troop 900 iOS UI Design Specification
// Appears at top of screen, auto-dismisses after 3 seconds, swipeable to dismiss

/// Toast notification style
public enum DSToastStyle {
    case success
    case error
    case info
    case warning
    
    public var backgroundColor: Color {
        switch self {
        case .success: return DSColors.success
        case .error: return DSColors.error
        case .info: return DSColors.info
        case .warning: return DSColors.warning
        }
    }
    
    public var icon: DSIcon {
        switch self {
        case .success: return .success
        case .error: return .critical
        case .info: return .infoFill
        case .warning: return .warning
        }
    }
}

/// Toast notification data model
public struct DSToastData: Equatable, Identifiable {
    public let id: UUID
    public let message: String
    public let style: DSToastStyle
    
    public init(message: String, style: DSToastStyle) {
        self.id = UUID()
        self.message = message
        self.style = style
    }
    
    public static func == (lhs: DSToastData, rhs: DSToastData) -> Bool {
        lhs.id == rhs.id
    }
    
    // Convenience initializers
    public static func success(_ message: String) -> DSToastData {
        DSToastData(message: message, style: .success)
    }
    
    public static func error(_ message: String) -> DSToastData {
        DSToastData(message: message, style: .error)
    }
    
    public static func info(_ message: String) -> DSToastData {
        DSToastData(message: message, style: .info)
    }
    
    public static func warning(_ message: String) -> DSToastData {
        DSToastData(message: message, style: .warning)
    }
}

// MARK: - Toast View

/// The actual toast notification view.
public struct DSToast: View {
    private let data: DSToastData
    private let onDismiss: () -> Void
    
    @State private var offset: CGFloat = 0
    
    public init(data: DSToastData, onDismiss: @escaping () -> Void) {
        self.data = data
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        HStack(spacing: DSSpacing.sm) {
            DSIconView(data.style.icon, size: .medium, color: DSColors.textOnPrimary)
            
            Text(data.message)
                .font(DSTypography.callout)
                .foregroundColor(DSColors.textOnPrimary)
                .lineLimit(2)
            
            Spacer(minLength: 0)
            
            Button(action: onDismiss) {
                DSIconView(.close, size: .small, color: DSColors.textOnPrimary.opacity(0.8))
            }
        }
        .padding(DSSpacing.md)
        .background(data.style.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
        .shadowLg()
        .offset(y: offset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.height < 0 {
                        offset = value.translation.height
                    }
                }
                .onEnded { value in
                    if value.translation.height < -50 {
                        withAnimation(.easeOut(duration: 0.2)) {
                            offset = -200
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            onDismiss()
                        }
                    } else {
                        withAnimation(.spring()) {
                            offset = 0
                        }
                    }
                }
        )
    }
}

// MARK: - Toast Container View Modifier

/// A view modifier that adds toast presentation capability to any view.
public struct DSToastModifier: ViewModifier {
    @Binding var toast: DSToastData?
    
    public func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            
            if let toastData = toast {
                DSToast(data: toastData) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        toast = nil
                    }
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.top, DSSpacing.sm)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(999)
                .onAppear {
                    // Auto-dismiss after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            toast = nil
                        }
                    }
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: toast)
    }
}

public extension View {
    /// Add toast notification support to a view.
    /// - Parameter toast: Binding to the toast data. Set to non-nil to show a toast.
    func toast(_ toast: Binding<DSToastData?>) -> some View {
        modifier(DSToastModifier(toast: toast))
    }
}

// MARK: - Toast Manager (Observable)

/// An observable object for managing toast notifications.
@MainActor
public class DSToastManager: ObservableObject {
    @Published public var currentToast: DSToastData?
    
    public init() {}
    
    public func show(_ toast: DSToastData) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            currentToast = toast
        }
    }
    
    public func showSuccess(_ message: String) {
        show(.success(message))
    }
    
    public func showError(_ message: String) {
        show(.error(message))
    }
    
    public func showInfo(_ message: String) {
        show(.info(message))
    }
    
    public func showWarning(_ message: String) {
        show(.warning(message))
    }
    
    public func dismiss() {
        withAnimation(.easeOut(duration: 0.2)) {
            currentToast = nil
        }
    }
}

// MARK: - Preset Toast Messages

public extension DSToastData {
    /// "You're all set! See you at the lot! 🌲"
    static var signUpSuccess: DSToastData {
        .success("You're all set! See you at the lot! 🌲")
    }
    
    /// "[Name] added and checked in!"
    static func walkInAdded(name: String) -> DSToastData {
        .success("\(name) added and checked in!")
    }
    
    /// "Announcement sent to [N] people"
    static func announcementSent(count: Int) -> DSToastData {
        .success("Announcement sent to \(count) people")
    }
    
    /// "Copied to clipboard"
    static var copiedToClipboard: DSToastData {
        .success("Copied to clipboard")
    }
    
    /// "Signup cancelled"
    static var signupCancelled: DSToastData {
        .info("Signup cancelled")
    }
}

// MARK: - Previews

#if DEBUG
struct DSToast_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var toast: DSToastData?
        
        var body: some View {
            VStack(spacing: DSSpacing.lg) {
                Text("Toast Previews").dsTitle2()
                
                DSPrimaryButton("Show Success") {
                    toast = .signUpSuccess
                }
                
                DSPrimaryButton("Show Error") {
                    toast = .error("Something went wrong. Please try again.")
                }
                
                DSPrimaryButton("Show Info") {
                    toast = .info("Signup cancelled")
                }
                
                DSPrimaryButton("Show Warning") {
                    toast = .warning("You're offline. Some features are unavailable.")
                }
                
                Spacer()
            }
            .padding()
            .toast($toast)
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}
#endif
