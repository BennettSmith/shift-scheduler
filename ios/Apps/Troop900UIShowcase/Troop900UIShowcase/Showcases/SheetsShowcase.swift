//
//  SheetsShowcase.swift
//  Troop900UIShowcase
//

import SwiftUI
import Troop900DesignSystem

struct SheetsShowcase: View {
    @State private var showSheet = false
    @State private var showConfirmation = false
    @State private var showSuccess = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                
                // Sheet Header
                showcaseSection("Sheet Header") {
                    DSCard {
                        DSSheetHeader(title: "Sign Up for Shift") { }
                    }
                }
                
                // Bottom Sheet Handle
                showcaseSection("Bottom Sheet Handle") {
                    DSCard {
                        VStack {
                            DSBottomSheetHandle()
                            Text("Drag indicator for bottom sheets")
                                .font(DSTypography.caption1)
                                .foregroundColor(DSColors.textTertiary)
                        }
                    }
                }
                
                // Shift Summary
                showcaseSection("Shift Summary") {
                    DSCard {
                        DSShiftSummary(
                            shiftName: "Saturday Morning",
                            date: "Nov 30",
                            time: "9:00 AM - 1:00 PM"
                        )
                    }
                }
                
                // Full Sheet Demo
                showcaseSection("Full Sheet Demo") {
                    DSPrimaryButton("Show Sheet") {
                        showSheet = true
                    }
                }
                
                // Confirmation Dialog
                showcaseSection("Confirmation Dialog") {
                    DSConfirmationDialog(
                        title: "Cancel Signup?",
                        message: "Are you sure you want to cancel your signup for this shift?",
                        confirmTitle: "Cancel Signup",
                        isDestructive: true,
                        onConfirm: { },
                        onCancel: { }
                    )
                }
                
                // Non-Destructive Confirmation
                showcaseSection("Non-Destructive Confirmation") {
                    DSConfirmationDialog(
                        title: "Send Announcement?",
                        message: "This will send a push notification to 24 people.",
                        confirmTitle: "Send",
                        isDestructive: false,
                        onConfirm: { },
                        onCancel: { }
                    )
                }
                
                // Interactive Confirmation
                showcaseSection("Interactive Confirmation") {
                    DSSecondaryButton("Show Confirmation Dialog") {
                        showConfirmation = true
                    }
                }
                
                // Success Sheet Demo
                showcaseSection("Success Sheet") {
                    DSSecondaryButton("Show Success Sheet") {
                        showSuccess = true
                    }
                }
                
                // Action Sheet Buttons
                showcaseSection("Action Sheet Buttons") {
                    DSCard {
                        VStack(spacing: 0) {
                            DSActionSheetButton("Edit Shift", icon: .edit) { }
                            Divider()
                            DSActionSheetButton("Share", icon: .share) { }
                            Divider()
                            DSActionSheetButton("Delete Shift", icon: .delete, style: .destructive) { }
                            Divider()
                            DSActionSheetButton("Cancel", style: .cancel) { }
                        }
                    }
                }
            }
            .padding()
        }
        .background(DSColors.neutral100)
        .navigationTitle("Sheets & Dialogs")
        .sheet(isPresented: $showSheet) {
            DSSheet(title: "Sign Up for Shift", onClose: { showSheet = false }) {
                VStack(alignment: .leading, spacing: DSSpacing.lg) {
                    DSShiftSummary(
                        shiftName: "Saturday Morning",
                        date: "Nov 30",
                        time: "9:00 AM - 1:00 PM"
                    )
                    
                    Text("Who's signing up?")
                        .font(DSTypography.headline)
                    
                    VStack(spacing: DSSpacing.sm) {
                        DSSelectionRow(title: "Sarah Smith (me)", trailingText: "Parent", isSelected: true) { }
                        DSSelectionRow(title: "Alex Smith", trailingText: "Scout", isSelected: false) { }
                    }
                    
                    Spacer()
                    
                    DSPrimaryButton("Confirm Sign Up") {
                        showSheet = false
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
        .alert("Sign Out?", isPresented: $showConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) { }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .sheet(isPresented: $showSuccess) {
            DSSuccessSheet(
                title: "Scout Linked!",
                message: "Alex Smith has been added to your household.",
                bulletPoints: [
                    "See all of Alex's shift assignments",
                    "Sign Alex up for new shifts",
                    "Check Alex in/out when you're working"
                ]
            ) {
                showSuccess = false
            }
            .presentationDetents([.medium])
        }
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
        SheetsShowcase()
    }
}
