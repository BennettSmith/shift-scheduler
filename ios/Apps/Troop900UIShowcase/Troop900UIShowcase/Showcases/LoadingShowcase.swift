//
//  LoadingShowcase.swift
//  Troop900UIShowcase
//

import SwiftUI
import Troop900DesignSystem

struct LoadingShowcase: View {
    @State private var showFullScreenLoading = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                
                // Loading Spinners
                showcaseSection("Loading Spinners") {
                    DSCard {
                        VStack(spacing: DSSpacing.lg) {
                            DSLoadingSpinner()
                            DSLoadingSpinner(message: "Loading shifts...")
                            DSLoadingSpinner(message: "Signing up...", color: DSColors.success)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                }
                
                // Full Screen Loading Demo
                showcaseSection("Full Screen Loading") {
                    DSSecondaryButton("Show Full Screen Loading") {
                        showFullScreenLoading = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showFullScreenLoading = false
                        }
                    }
                    
                    Text("Loading will dismiss after 2 seconds")
                        .font(DSTypography.caption1)
                        .foregroundColor(DSColors.textTertiary)
                }
                
                // Skeleton Components
                showcaseSection("Skeleton Placeholders") {
                    VStack(spacing: DSSpacing.md) {
                        DSSkeleton(width: 200, height: 20)
                        DSSkeleton(height: 16)
                        DSSkeleton(width: 150, height: 14)
                    }
                    .padding()
                    .background(DSColors.backgroundElevated)
                    .cornerRadius(DSRadius.md)
                }
                
                // Skeleton Card
                showcaseSection("Skeleton Card") {
                    DSSkeletonCard()
                }
                
                // Skeleton Shift Card
                showcaseSection("Skeleton Shift Card") {
                    DSSkeletonShiftCard()
                }
                
                // Skeleton Week Card
                showcaseSection("Skeleton Week Card") {
                    DSSkeletonWeekCard()
                }
                
                // Skeleton Rows
                showcaseSection("Skeleton Rows") {
                    DSGroupedList {
                        DSSkeletonRow()
                        DSDivider()
                        DSSkeletonRow(hasIcon: false)
                        DSDivider()
                        DSSkeletonRow(hasChevron: false)
                    }
                }
                
                // Skeleton Profile Header
                showcaseSection("Skeleton Profile Header") {
                    DSCard {
                        DSSkeletonProfileHeader()
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
            }
            .padding()
        }
        .background(DSColors.neutral100)
        .navigationTitle("Loading States")
        .overlay {
            if showFullScreenLoading {
                DSFullScreenLoading(message: "Processing...")
            }
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
        LoadingShowcase()
    }
}
