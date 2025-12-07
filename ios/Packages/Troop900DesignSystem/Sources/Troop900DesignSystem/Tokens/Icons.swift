import SwiftUI

// MARK: - Design System Icons
// Based on Troop 900 iOS UI Design Specification
// Uses SF Symbols throughout for iOS consistency

/// SF Symbol icon names used throughout the app.
/// Provides type-safe access to icon names and convenience methods.
public enum DSIcon: String, CaseIterable {
    // MARK: - Tab Bar Icons
    
    /// Home tab (inactive)
    case home = "house"
    /// Home tab (active)
    case homeFill = "house.fill"
    
    /// Schedule tab (inactive)
    case calendar = "calendar"
    /// Schedule tab (active)
    case calendarFill = "calendar.fill"
    
    /// Check-In tab (inactive)
    case checkIn = "checkmark.circle"
    /// Check-In tab (active)
    case checkInFill = "checkmark.circle.fill"
    
    /// Profile tab (inactive)
    case profile = "person"
    /// Profile tab (active)
    case profileFill = "person.fill"
    
    /// Committee tab (inactive)
    case committee = "shield"
    /// Committee tab (active)
    case committeeFill = "shield.fill"
    
    // MARK: - Entity Icons
    
    /// Scout indicator
    case scout = "tent.fill"
    
    /// Parent/person indicator (uses person.2 to avoid conflict with profileFill)
    case parent = "person.crop.circle"
    
    /// Multiple people / parents
    case people = "person.2.fill"
    
    /// Family
    case family = "figure.2.and.child.holdinghands"
    
    /// Household (uses house.circle to avoid conflict with homeFill)
    case household = "house.circle.fill"
    
    // MARK: - Status Icons
    
    /// Fully staffed / confirmed / success (uses checkmark.seal to avoid conflict)
    case success = "checkmark.seal.fill"
    
    /// Needs attention / warning
    case warning = "exclamationmark.circle.fill"
    
    /// Critical / error
    case critical = "xmark.circle.fill"
    
    /// Signed up / starred
    case starred = "star.fill"
    
    /// Star outline (not starred)
    case star = "star"
    
    // MARK: - Action Icons
    
    /// Add / Plus action
    case add = "plus.circle.fill"
    
    /// Plus (simple)
    case plus = "plus"
    
    /// Settings / gear
    case settings = "gearshape"
    
    /// Sign out
    case signOut = "rectangle.portrait.and.arrow.right"
    
    /// Edit / pencil
    case edit = "pencil"
    
    /// Delete / trash
    case delete = "trash"
    
    /// Share
    case share = "square.and.arrow.up"
    
    /// Copy
    case copy = "doc.on.doc"
    
    /// Search
    case search = "magnifyingglass"
    
    /// Close / X
    case close = "xmark"
    
    /// Chevron right (navigation)
    case chevronRight = "chevron.right"
    
    /// Chevron down (expand)
    case chevronDown = "chevron.down"
    
    /// Chevron up (collapse)
    case chevronUp = "chevron.up"
    
    // MARK: - Misc Icons
    
    /// Location pin
    case location = "mappin"
    
    /// Clock / time
    case clock = "clock"
    
    /// Bell / notification
    case bell = "bell"
    
    /// Bell with badge
    case bellBadge = "bell.badge"
    
    /// Info
    case info = "info.circle"
    
    /// Info filled
    case infoFill = "info.circle.fill"
    
    /// Question / help
    case help = "questionmark.circle"
    
    /// Wifi off (offline)
    case offline = "wifi.slash"
    
    /// Refresh / retry
    case refresh = "arrow.clockwise"
    
    /// Export / download
    case export = "square.and.arrow.down"
    
    /// Megaphone / announcement
    case announcement = "megaphone"
    
    /// Document / report
    case document = "doc.text"
    
    /// Chart / statistics
    case chart = "chart.bar"
    
    /// Tree (for tree lot branding)
    case tree = "tree"
    
    // MARK: - Image Creation
    
    /// Create an SF Symbol Image with default rendering
    public var image: Image {
        Image(systemName: rawValue)
    }
    
    /// Create an SF Symbol Image with specified size
    public func image(size: CGFloat) -> some View {
        Image(systemName: rawValue)
            .font(.system(size: size))
    }
}

// MARK: - Icon View Component

/// A reusable icon view with consistent styling.
public struct DSIconView: View {
    private let icon: DSIcon
    private let size: IconSize
    private let color: Color?
    
    public enum IconSize {
        case small      // 16pt
        case medium     // 20pt
        case large      // 24pt
        case xlarge     // 32pt
        case xxlarge    // 48pt
        case custom(CGFloat)
        
        var pointSize: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 20
            case .large: return 24
            case .xlarge: return 32
            case .xxlarge: return 48
            case .custom(let size): return size
            }
        }
    }
    
    public init(_ icon: DSIcon, size: IconSize = .medium, color: Color? = nil) {
        self.icon = icon
        self.size = size
        self.color = color
    }
    
    public var body: some View {
        Image(systemName: icon.rawValue)
            .font(.system(size: size.pointSize))
            .foregroundColor(color)
    }
}

// MARK: - Convenience Functions

public extension Image {
    /// Create an Image from a DSIcon
    init(dsIcon: DSIcon) {
        self.init(systemName: dsIcon.rawValue)
    }
}

// MARK: - Tab Bar Icon Pair

/// Helper struct for tab bar icons (provides both active and inactive states)
public struct TabBarIcon {
    public let inactive: DSIcon
    public let active: DSIcon
    
    public static let home = TabBarIcon(inactive: .home, active: .homeFill)
    public static let schedule = TabBarIcon(inactive: .calendar, active: .calendarFill)
    public static let checkIn = TabBarIcon(inactive: .checkIn, active: .checkInFill)
    public static let profile = TabBarIcon(inactive: .profile, active: .profileFill)
    public static let committee = TabBarIcon(inactive: .committee, active: .committeeFill)
}
