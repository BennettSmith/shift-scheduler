//
//  ColorsShowcase.swift
//  Troop900UIShowcase
//

import SwiftUI
import Troop900DesignSystem

struct ColorsShowcase: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                
                // Primary Colors
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    Text("Primary Colors")
                        .font(DSTypography.title2)
                    
                    Text("CalTrans Orange - the main accent color")
                        .font(DSTypography.callout)
                        .foregroundColor(DSColors.textSecondary)
                    
                    HStack(spacing: DSSpacing.md) {
                        ColorSwatch(color: DSColors.primary, name: "Primary", hex: "#FF6D00")
                        ColorSwatch(color: DSColors.primaryDark, name: "Primary Dark", hex: "#E65100")
                        ColorSwatch(color: DSColors.primaryLight, name: "Primary Light", hex: "#FFF3E0")
                    }
                }
                
                // Semantic Colors
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    Text("Semantic Colors")
                        .font(DSTypography.title2)
                    
                    Text("Colors with specific meanings")
                        .font(DSTypography.callout)
                        .foregroundColor(DSColors.textSecondary)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DSSpacing.md) {
                        ColorSwatch(color: DSColors.success, name: "Success", hex: "#2E7D32")
                        ColorSwatch(color: DSColors.successLight, name: "Success Light", hex: "#E8F5E9")
                        ColorSwatch(color: DSColors.warning, name: "Warning", hex: "#F9A825")
                        ColorSwatch(color: DSColors.warningLight, name: "Warning Light", hex: "#FFF8E1")
                        ColorSwatch(color: DSColors.error, name: "Error", hex: "#C62828")
                        ColorSwatch(color: DSColors.errorLight, name: "Error Light", hex: "#FFEBEE")
                        ColorSwatch(color: DSColors.info, name: "Info", hex: "#1565C0")
                        ColorSwatch(color: DSColors.infoLight, name: "Info Light", hex: "#E3F2FD")
                    }
                }
                
                // Neutral Colors
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    Text("Neutral Colors")
                        .font(DSTypography.title2)
                    
                    Text("Grays for text, backgrounds, and borders")
                        .font(DSTypography.callout)
                        .foregroundColor(DSColors.textSecondary)
                    
                    VStack(spacing: DSSpacing.sm) {
                        NeutralColorRow(color: DSColors.neutral900, name: "Neutral 900", hex: "#1A1A1A", usage: "Primary text")
                        NeutralColorRow(color: DSColors.neutral700, name: "Neutral 700", hex: "#4A4A4A", usage: "Secondary text")
                        NeutralColorRow(color: DSColors.neutral500, name: "Neutral 500", hex: "#8A8A8A", usage: "Tertiary text")
                        NeutralColorRow(color: DSColors.neutral300, name: "Neutral 300", hex: "#B0B0B0", usage: "Disabled")
                        NeutralColorRow(color: DSColors.neutral200, name: "Neutral 200", hex: "#E5E5E5", usage: "Borders")
                        NeutralColorRow(color: DSColors.neutral100, name: "Neutral 100", hex: "#F5F5F5", usage: "Card backgrounds")
                        NeutralColorRow(color: DSColors.neutral0, name: "Neutral 0", hex: "#FFFFFF", usage: "Page backgrounds")
                    }
                }
            }
            .padding()
        }
        .background(DSColors.neutral100)
        .navigationTitle("Colors")
    }
}

struct ColorSwatch: View {
    let color: Color
    let name: String
    let hex: String
    
    var body: some View {
        VStack(spacing: DSSpacing.xs) {
            RoundedRectangle(cornerRadius: DSRadius.md)
                .fill(color)
                .frame(height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.md)
                        .stroke(DSColors.neutral200, lineWidth: 1)
                )
            
            Text(name)
                .font(DSTypography.caption1)
                .foregroundColor(DSColors.textPrimary)
            
            Text(hex)
                .font(DSTypography.caption2)
                .foregroundColor(DSColors.textTertiary)
        }
    }
}

struct NeutralColorRow: View {
    let color: Color
    let name: String
    let hex: String
    let usage: String
    
    var body: some View {
        HStack(spacing: DSSpacing.md) {
            RoundedRectangle(cornerRadius: DSRadius.sm)
                .fill(color)
                .frame(width: 44, height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.sm)
                        .stroke(DSColors.neutral200, lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(DSTypography.headline)
                    .foregroundColor(DSColors.textPrimary)
                
                Text("\(hex) • \(usage)")
                    .font(DSTypography.caption1)
                    .foregroundColor(DSColors.textTertiary)
            }
            
            Spacer()
        }
        .padding(DSSpacing.sm)
        .background(DSColors.backgroundElevated)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
    }
}

#Preview {
    NavigationStack {
        ColorsShowcase()
    }
}
