//
//  AvatarShowcase.swift
//  Troop900UIShowcase
//

import SwiftUI
import Troop900DesignSystem

struct AvatarShowcase: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                
                // Avatar Sizes
                showcaseSection("Avatar Sizes") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DSSpacing.lg) {
                            VStack {
                                DSAvatar(.initials("SS"), size: .small)
                                Text("Small").font(DSTypography.caption2)
                            }
                            VStack {
                                DSAvatar(.initials("SS"), size: .medium)
                                Text("Medium").font(DSTypography.caption2)
                            }
                            VStack {
                                DSAvatar(.initials("SS"), size: .large)
                                Text("Large").font(DSTypography.caption2)
                            }
                            VStack {
                                DSAvatar(.initials("SS"), size: .xlarge)
                                Text("XLarge").font(DSTypography.caption2)
                            }
                            VStack {
                                DSAvatar(.initials("SS"), size: .profile)
                                Text("Profile").font(DSTypography.caption2)
                            }
                        }
                        .foregroundColor(DSColors.textSecondary)
                    }
                }
                
                // Avatar from Name
                showcaseSection("Avatar from Name") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DSSpacing.lg) {
                            VStack {
                                DSAvatar.fromName("Sarah Smith", size: .large)
                                Text("Sarah Smith").font(DSTypography.caption2)
                            }
                            VStack {
                                DSAvatar.fromName("Alex", size: .large)
                                Text("Alex").font(DSTypography.caption2)
                            }
                            VStack {
                                DSAvatar.fromName("John Davis", size: .large)
                                Text("John Davis").font(DSTypography.caption2)
                            }
                        }
                        .foregroundColor(DSColors.textSecondary)
                    }
                }
                
                // Avatar with Icons
                showcaseSection("Avatar with Icons") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DSSpacing.lg) {
                            VStack {
                                DSAvatar.person(size: .large)
                                Text("Person").font(DSTypography.caption2)
                            }
                            VStack {
                                DSAvatar.scout(size: .large)
                                Text("Scout").font(DSTypography.caption2)
                            }
                            VStack {
                                DSAvatar(.icon(.family), size: .large)
                                Text("Family").font(DSTypography.caption2)
                            }
                        }
                        .foregroundColor(DSColors.textSecondary)
                    }
                }
                
                // Custom Colors
                showcaseSection("Custom Colors") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DSSpacing.lg) {
                            DSAvatar(
                                .initials("SS"),
                                size: .large,
                                backgroundColor: DSColors.successLight,
                                foregroundColor: DSColors.success
                            )
                            DSAvatar(
                                .initials("AS"),
                                size: .large,
                                backgroundColor: DSColors.warningLight,
                                foregroundColor: DSColors.warning
                            )
                            DSAvatar(
                                .initials("JD"),
                                size: .large,
                                backgroundColor: DSColors.infoLight,
                                foregroundColor: DSColors.info
                            )
                        }
                    }
                }
                
                // Profile Headers
                showcaseSection("Profile Headers") {
                    DSCard {
                        DSProfileHeader(
                            name: "Sarah Smith",
                            subtitle: "Parent • Smith Family"
                        )
                    }
                    
                    DSCard {
                        DSProfileHeader(
                            name: "Alex Smith",
                            subtitle: "Scout • Smith Family",
                            secondarySubtitle: "Also in: Johnson Household",
                            avatarContent: .icon(.scout)
                        )
                    }
                }
                
                // In Context
                showcaseSection("In Context: Person Row") {
                    DSGroupedList {
                        HStack(spacing: DSSpacing.md) {
                            DSAvatar.fromName("Sarah Smith", size: .medium)
                            VStack(alignment: .leading) {
                                Text("Sarah Smith")
                                    .font(DSTypography.headline)
                                Text("sarah@email.com")
                                    .font(DSTypography.caption1)
                                    .foregroundColor(DSColors.textTertiary)
                            }
                            Spacer()
                            DSRoleBadge(.primary)
                            DSIconView(.chevronRight, size: .small, color: DSColors.textTertiary)
                        }
                        .padding(DSSpacing.md)
                        
                        DSDivider()
                        
                        HStack(spacing: DSSpacing.md) {
                            DSAvatar(.icon(.scout), size: .medium)
                            VStack(alignment: .leading) {
                                Text("Alex Smith")
                                    .font(DSTypography.headline)
                                Text("Has own account")
                                    .font(DSTypography.caption1)
                                    .foregroundColor(DSColors.textTertiary)
                            }
                            Spacer()
                            DSRoleBadge(.claimed)
                            DSIconView(.chevronRight, size: .small, color: DSColors.textTertiary)
                        }
                        .padding(DSSpacing.md)
                    }
                }
            }
            .padding()
        }
        .background(DSColors.neutral100)
        .navigationTitle("Avatars & Profile")
    }
    
    @ViewBuilder
    private func showcaseSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            Text(title)
                .font(DSTypography.headline)
                .foregroundColor(DSColors.textPrimary)
            
            content()
        }
    }
}

#Preview {
    NavigationStack {
        AvatarShowcase()
    }
}
