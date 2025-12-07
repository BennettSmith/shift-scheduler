import SwiftUI

// MARK: - Design System Avatar
// Based on Troop 900 iOS UI Design Specification

/// Avatar size options.
public enum DSAvatarSize {
    case small      // 32pt
    case medium     // 48pt
    case large      // 64pt
    case xlarge     // 80pt
    case profile    // 100pt
    
    var diameter: CGFloat {
        switch self {
        case .small: return 32
        case .medium: return 48
        case .large: return 64
        case .xlarge: return 80
        case .profile: return 100
        }
    }
    
    var iconSize: DSIconView.IconSize {
        switch self {
        case .small: return .small
        case .medium: return .medium
        case .large: return .large
        case .xlarge: return .xlarge
        case .profile: return .xxlarge
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 18
        case .large: return 24
        case .xlarge: return 32
        case .profile: return 40
        }
    }
}

/// An avatar component showing either initials, an icon, or an image.
public struct DSAvatar: View {
    public enum Content {
        case initials(String)
        case icon(DSIcon)
        case image(Image)
    }
    
    private let content: Content
    private let size: DSAvatarSize
    private let backgroundColor: Color
    private let foregroundColor: Color
    
    public init(
        _ content: Content,
        size: DSAvatarSize = .medium,
        backgroundColor: Color = DSColors.primaryLight,
        foregroundColor: Color = DSColors.primary
    ) {
        self.content = content
        self.size = size
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    
    public var body: some View {
        Circle()
            .fill(imageBackground)
            .frame(width: size.diameter, height: size.diameter)
            .overlay {
                switch content {
                case .initials(let initials):
                    Text(initials.prefix(2).uppercased())
                        .font(.system(size: size.fontSize, weight: .semibold))
                        .foregroundColor(foregroundColor)
                
                case .icon(let icon):
                    DSIconView(icon, size: size.iconSize, color: foregroundColor)
                
                case .image(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                }
            }
    }
    
    /// Returns the appropriate background - clear for images (since they cover it), 
    /// or the specified backgroundColor for initials/icons
    private var imageBackground: Color {
        switch content {
        case .image:
            return DSColors.neutral200 // Neutral background for images (visible if image has transparency)
        case .initials, .icon:
            return backgroundColor
        }
    }
}

// MARK: - Convenience Initializers

public extension DSAvatar {
    /// Create an avatar from a person's name (extracts initials).
    static func fromName(_ name: String, size: DSAvatarSize = .medium) -> DSAvatar {
        let initials = name.split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map { String($0) }
            .joined()
        
        return DSAvatar(.initials(initials), size: size)
    }
    
    /// Create an avatar with a person icon.
    static func person(size: DSAvatarSize = .medium) -> DSAvatar {
        DSAvatar(.icon(.profileFill), size: size)
    }
    
    /// Create an avatar with a scout icon.
    static func scout(size: DSAvatarSize = .medium) -> DSAvatar {
        DSAvatar(.icon(.scout), size: size)
    }
}

// MARK: - Profile Header

/// A profile header component with avatar, name, and subtitle.
public struct DSProfileHeader: View {
    private let name: String
    private let subtitle: String
    private let secondarySubtitle: String?
    private let avatarContent: DSAvatar.Content
    
    public init(
        name: String,
        subtitle: String,
        secondarySubtitle: String? = nil,
        avatarContent: DSAvatar.Content? = nil
    ) {
        self.name = name
        self.subtitle = subtitle
        self.secondarySubtitle = secondarySubtitle
        self.avatarContent = avatarContent ?? .initials(
            name.split(separator: " ")
                .prefix(2)
                .compactMap { $0.first }
                .map { String($0) }
                .joined()
        )
    }
    
    public var body: some View {
        VStack(spacing: DSSpacing.sm) {
            DSAvatar(avatarContent, size: .profile)
            
            Text(name)
                .font(DSTypography.title1)
                .foregroundColor(DSColors.textPrimary)
            
            Text(subtitle)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textSecondary)
            
            if let secondary = secondarySubtitle {
                Text(secondary)
                    .font(DSTypography.caption1)
                    .foregroundColor(DSColors.textTertiary)
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
struct DSAvatar_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: DSSpacing.xl) {
                Group {
                    Text("Avatar Sizes").dsHeadline()
                    
                    HStack(spacing: DSSpacing.md) {
                        DSAvatar(.initials("SS"), size: .small)
                        DSAvatar(.initials("SS"), size: .medium)
                        DSAvatar(.initials("SS"), size: .large)
                        DSAvatar(.initials("SS"), size: .xlarge)
                    }
                }
                
                Group {
                    Text("Avatar Types").dsHeadline()
                    
                    HStack(spacing: DSSpacing.md) {
                        DSAvatar.fromName("Sarah Smith")
                        DSAvatar.person()
                        DSAvatar.scout()
                    }
                }
                
                Divider()
                
                Group {
                    Text("Profile Headers").dsHeadline()
                    
                    DSProfileHeader(
                        name: "Sarah Smith",
                        subtitle: "Parent • Smith Family"
                    )
                    
                    DSProfileHeader(
                        name: "Alex Smith",
                        subtitle: "Scout • Smith Family",
                        secondarySubtitle: "Also in: Johnson Household",
                        avatarContent: .icon(.scout)
                    )
                }
            }
            .padding()
        }
    }
}
#endif
