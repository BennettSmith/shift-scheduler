//
//  StatusBadgesShowcase.swift
//  Troop900UIShowcase
//

import SwiftUI
import Troop900DesignSystem

struct StatusBadgesShowcase: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                
                // Status Badges
                showcaseSection("Status Badges") {
                    VStack(alignment: .leading, spacing: DSSpacing.md) {
                        HStack(spacing: DSSpacing.md) {
                            DSStatusBadge("Fully staffed", status: .success)
                            DSStatusBadge("Needs help", status: .warning)
                            DSStatusBadge("Critical", status: .critical)
                        }
                        HStack(spacing: DSSpacing.md) {
                            DSStatusBadge("Signed up", status: .signedUp)
                            DSStatusBadge("Info", status: .info)
                            DSStatusBadge("Default", status: .neutral)
                        }
                    }
                }
                
                // Without Icons
                showcaseSection("Status Badges (No Icons)") {
                    HStack(spacing: DSSpacing.md) {
                        DSStatusBadge("Success", status: .success, showIcon: false)
                        DSStatusBadge("Warning", status: .warning, showIcon: false)
                        DSStatusBadge("Error", status: .critical, showIcon: false)
                    }
                }
                
                // Staffing Badges
                showcaseSection("Staffing Badges") {
                    VStack(alignment: .leading, spacing: DSSpacing.md) {
                        DSStaffingBadge(.fullyStaffed)
                        DSStaffingBadge(.needsHelp("Needs scouts"))
                        DSStaffingBadge(.needsHelp("Needs parents"))
                        DSStaffingBadge(.needsHelp("Needs help"))
                        DSStaffingBadge(.critical)
                    }
                }
                
                // Role Badges
                showcaseSection("Role Badges") {
                    VStack(alignment: .leading, spacing: DSSpacing.md) {
                        HStack(spacing: DSSpacing.md) {
                            DSRoleBadge(.parent)
                            DSRoleBadge(.scout)
                            DSRoleBadge(.admin)
                            DSRoleBadge(.committee)
                        }
                        HStack(spacing: DSSpacing.md) {
                            DSRoleBadge(.primary)
                            DSRoleBadge(.spouse)
                            DSRoleBadge(.claimed)
                            DSRoleBadge(.unclaimed)
                        }
                    }
                }
                
                // Check-In Status Badges
                showcaseSection("Check-In Status") {
                    VStack(alignment: .leading, spacing: DSSpacing.md) {
                        DSCheckInStatusBadge(.notCheckedIn)
                        DSCheckInStatusBadge(.checkedIn(time: "9:58 AM"))
                        DSCheckInStatusBadge(.checkedOut(time: "1:05 PM"))
                        DSCheckInStatusBadge(.noShow)
                    }
                }
                
                // Staffing Count Badges
                showcaseSection("Staffing Counts") {
                    VStack(alignment: .leading, spacing: DSSpacing.md) {
                        HStack(spacing: DSSpacing.lg) {
                            DSStaffingCountBadge(type: .scout, current: 2, required: 3)
                            DSStaffingCountBadge(type: .parent, current: 1, required: 2)
                        }
                        HStack(spacing: DSSpacing.lg) {
                            DSStaffingCountBadge(type: .scout, current: 3, required: 3)
                            DSStaffingCountBadge(type: .parent, current: 2, required: 2)
                        }
                    }
                }
                
                // Leaderboard Ranks
                showcaseSection("Leaderboard Ranks") {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        HStack {
                            DSRankBadge(rank: 1)
                            Text("Alex Smith")
                                .font(DSTypography.body)
                            Spacer()
                            Text("18.5 hrs")
                                .font(DSTypography.body)
                                .foregroundColor(DSColors.textSecondary)
                        }
                        HStack {
                            DSRankBadge(rank: 2)
                            Text("Emma Wilson")
                                .font(DSTypography.body)
                            Spacer()
                            Text("16.0 hrs")
                                .font(DSTypography.body)
                                .foregroundColor(DSColors.textSecondary)
                        }
                        HStack {
                            DSRankBadge(rank: 3)
                            Text("Jake Thompson")
                                .font(DSTypography.body)
                            Spacer()
                            Text("14.5 hrs")
                                .font(DSTypography.body)
                                .foregroundColor(DSColors.textSecondary)
                        }
                        HStack {
                            DSRankBadge(rank: 4, isCurrentUser: true)
                            Text("Sarah Smith (you)")
                                .font(DSTypography.body)
                                .foregroundColor(DSColors.primary)
                            Spacer()
                            Text("12.5 hrs")
                                .font(DSTypography.body)
                                .foregroundColor(DSColors.textSecondary)
                        }
                        HStack {
                            DSRankBadge(rank: 5)
                            Text("John Davis")
                                .font(DSTypography.body)
                            Spacer()
                            Text("11.0 hrs")
                                .font(DSTypography.body)
                                .foregroundColor(DSColors.textSecondary)
                        }
                    }
                    .padding()
                    .background(DSColors.backgroundElevated)
                    .cornerRadius(DSRadius.md)
                }
            }
            .padding()
        }
        .background(DSColors.neutral100)
        .navigationTitle("Status Badges")
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
        StatusBadgesShowcase()
    }
}
