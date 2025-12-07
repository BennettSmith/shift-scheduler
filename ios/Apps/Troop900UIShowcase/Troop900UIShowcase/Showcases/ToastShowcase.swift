//
//  ToastShowcase.swift
//  Troop900UIShowcase
//

import SwiftUI
import Troop900DesignSystem

struct ToastShowcase: View {
    @State private var toast: DSToastData?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                
                // Info
                showcaseSection("About Toasts") {
                    DSInfoCard("Toasts appear at the top of the screen, auto-dismiss after 3 seconds, and can be swiped up to dismiss early.", style: .info)
                }
                
                // Success Toast
                showcaseSection("Success Toast") {
                    DSPrimaryButton("Show Success Toast") {
                        toast = .signUpSuccess
                    }
                    
                    DSSecondaryButton("Custom Success") {
                        toast = .success("Changes saved successfully!")
                    }
                }
                
                // Error Toast
                showcaseSection("Error Toast") {
                    DSPrimaryButton("Show Error Toast") {
                        toast = .error("Something went wrong. Please try again.")
                    }
                }
                
                // Info Toast
                showcaseSection("Info Toast") {
                    DSPrimaryButton("Show Info Toast") {
                        toast = .signupCancelled
                    }
                    
                    DSSecondaryButton("Custom Info") {
                        toast = .info("Your preferences have been updated.")
                    }
                }
                
                // Warning Toast
                showcaseSection("Warning Toast") {
                    DSPrimaryButton("Show Warning Toast") {
                        toast = .warning("You're running low on storage.")
                    }
                }
                
                // Preset Toasts
                showcaseSection("Preset Toasts") {
                    VStack(spacing: DSSpacing.md) {
                        DSSecondaryButton("Sign Up Success") {
                            toast = .signUpSuccess
                        }
                        
                        DSSecondaryButton("Walk-In Added") {
                            toast = .walkInAdded(name: "Jake Thompson")
                        }
                        
                        DSSecondaryButton("Announcement Sent") {
                            toast = .announcementSent(count: 24)
                        }
                        
                        DSSecondaryButton("Copied to Clipboard") {
                            toast = .copiedToClipboard
                        }
                    }
                }
                
                // Static Previews
                showcaseSection("Toast Styles (Static)") {
                    VStack(spacing: DSSpacing.md) {
                        staticToast(style: .success, message: "Success message")
                        staticToast(style: .error, message: "Error message")
                        staticToast(style: .info, message: "Info message")
                        staticToast(style: .warning, message: "Warning message")
                    }
                }
            }
            .padding()
        }
        .background(DSColors.neutral100)
        .navigationTitle("Toasts")
        .toast($toast)
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
    
    @ViewBuilder
    private func staticToast(style: DSToastStyle, message: String) -> some View {
        HStack(spacing: DSSpacing.sm) {
            DSIconView(style.icon, size: .medium, color: DSColors.textOnPrimary)
            
            Text(message)
                .font(DSTypography.callout)
                .foregroundColor(DSColors.textOnPrimary)
            
            Spacer()
        }
        .padding(DSSpacing.md)
        .background(style.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
    }
}

#Preview {
    NavigationStack {
        ToastShowcase()
    }
}
