//
//  SpacingShowcase.swift
//  Troop900UIShowcase
//

import SwiftUI
import Troop900DesignSystem

struct SpacingShowcase: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                
                // Spacing Scale
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    Text("Spacing Scale")
                        .font(DSTypography.title2)
                    
                    VStack(spacing: DSSpacing.sm) {
                        SpacingRow(name: "xs", value: DSSpacing.xs, usage: "Tight spacing, inline elements")
                        SpacingRow(name: "sm", value: DSSpacing.sm, usage: "Related elements")
                        SpacingRow(name: "md", value: DSSpacing.md, usage: "Standard padding, gaps")
                        SpacingRow(name: "lg", value: DSSpacing.lg, usage: "Section spacing")
                        SpacingRow(name: "xl", value: DSSpacing.xl, usage: "Major sections")
                        SpacingRow(name: "xxl", value: DSSpacing.xxl, usage: "Screen-level spacing")
                    }
                }
                
                // Corner Radius
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    Text("Corner Radius")
                        .font(DSTypography.title2)
                    
                    HStack(spacing: DSSpacing.lg) {
                        RadiusExample(name: "sm", radius: DSRadius.sm, usage: "Buttons")
                        RadiusExample(name: "md", radius: DSRadius.md, usage: "Cards")
                        RadiusExample(name: "lg", radius: DSRadius.lg, usage: "Sheets")
                        RadiusExample(name: "full", radius: DSRadius.full, usage: "Pills")
                    }
                }
                
                // Shadows
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    Text("Shadows")
                        .font(DSTypography.title2)
                    
                    HStack(spacing: DSSpacing.lg) {
                        ShadowExample(name: "sm", description: "Subtle lift")
                            .shadowSm()
                        
                        ShadowExample(name: "md", description: "Cards")
                            .shadowMd()
                        
                        ShadowExample(name: "lg", description: "Floating")
                            .shadowLg()
                    }
                }
                
                // View Modifiers
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    Text("Convenience Modifiers")
                        .font(DSTypography.title2)
                    
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Text(".cardPadding() → 16pt all sides")
                            .font(DSTypography.callout)
                        
                        Text(".sectionSpacing() → 24pt vertical")
                            .font(DSTypography.callout)
                        
                        Text(".screenPadding() → 16pt horizontal")
                            .font(DSTypography.callout)
                        
                        Text(".shadowSm() / .shadowMd() / .shadowLg()")
                            .font(DSTypography.callout)
                        
                        Text(".cornerRadiusSm() / .cornerRadiusMd() / .cornerRadiusLg()")
                            .font(DSTypography.callout)
                    }
                    .padding()
                    .background(DSColors.backgroundElevated)
                    .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
                }
            }
            .padding()
        }
        .background(DSColors.neutral100)
        .navigationTitle("Spacing & Radius")
    }
}

struct SpacingRow: View {
    let name: String
    let value: CGFloat
    let usage: String
    
    var body: some View {
        HStack(spacing: DSSpacing.md) {
            RoundedRectangle(cornerRadius: 4)
                .fill(DSColors.primary)
                .frame(width: value, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("DSSpacing.\(name)")
                    .font(DSTypography.headline)
                
                Text("\(Int(value))pt • \(usage)")
                    .font(DSTypography.caption1)
                    .foregroundColor(DSColors.textTertiary)
            }
            
            Spacer()
        }
        .padding()
        .background(DSColors.backgroundElevated)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
    }
}

struct RadiusExample: View {
    let name: String
    let radius: CGFloat
    let usage: String
    
    var body: some View {
        VStack(spacing: DSSpacing.xs) {
            RoundedRectangle(cornerRadius: radius)
                .fill(DSColors.primary)
                .frame(width: 60, height: 60)
            
            Text(name)
                .font(DSTypography.caption1)
            
            Text("\(Int(radius))pt")
                .font(DSTypography.caption2)
                .foregroundColor(DSColors.textTertiary)
        }
    }
}

struct ShadowExample: View {
    let name: String
    let description: String
    
    var body: some View {
        VStack(spacing: DSSpacing.xs) {
            RoundedRectangle(cornerRadius: DSRadius.md)
                .fill(DSColors.backgroundElevated)
                .frame(width: 80, height: 60)
            
            Text(name)
                .font(DSTypography.caption1)
            
            Text(description)
                .font(DSTypography.caption2)
                .foregroundColor(DSColors.textTertiary)
        }
    }
}

#Preview {
    NavigationStack {
        SpacingShowcase()
    }
}
