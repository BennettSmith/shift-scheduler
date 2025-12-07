//
//  TypographyShowcase.swift
//  Troop900UIShowcase
//

import SwiftUI
import Troop900DesignSystem

struct TypographyShowcase: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                
                Text("All typography uses San Francisco (iOS system font)")
                    .font(DSTypography.callout)
                    .foregroundColor(DSColors.textSecondary)
                    .padding(.bottom)
                
                TypographyRow(
                    name: "Large Title",
                    font: DSTypography.largeTitle,
                    specs: "Bold 34pt",
                    usage: "Screen titles"
                )
                
                TypographyRow(
                    name: "Title 1",
                    font: DSTypography.title1,
                    specs: "Bold 28pt",
                    usage: "Section headers"
                )
                
                TypographyRow(
                    name: "Title 2",
                    font: DSTypography.title2,
                    specs: "Bold 22pt",
                    usage: "Card titles"
                )
                
                TypographyRow(
                    name: "Title 3",
                    font: DSTypography.title3,
                    specs: "Semibold 20pt",
                    usage: "Subsection headers"
                )
                
                TypographyRow(
                    name: "Headline",
                    font: DSTypography.headline,
                    specs: "Semibold 17pt",
                    usage: "List item titles"
                )
                
                TypographyRow(
                    name: "Body",
                    font: DSTypography.body,
                    specs: "Regular 17pt",
                    usage: "Primary content"
                )
                
                TypographyRow(
                    name: "Callout",
                    font: DSTypography.callout,
                    specs: "Regular 16pt",
                    usage: "Supporting content"
                )
                
                TypographyRow(
                    name: "Subhead",
                    font: DSTypography.subhead,
                    specs: "Regular 15pt",
                    usage: "Secondary labels"
                )
                
                TypographyRow(
                    name: "Footnote",
                    font: DSTypography.footnote,
                    specs: "Regular 13pt",
                    usage: "Tertiary information"
                )
                
                TypographyRow(
                    name: "Caption 1",
                    font: DSTypography.caption1,
                    specs: "Regular 12pt",
                    usage: "Timestamps, metadata"
                )
                
                TypographyRow(
                    name: "Caption 2",
                    font: DSTypography.caption2,
                    specs: "Regular 11pt",
                    usage: "Badges, small labels"
                )
                
                Divider()
                    .padding(.vertical)
                
                Text("Text Style Helpers")
                    .font(DSTypography.title2)
                    .padding(.bottom, DSSpacing.sm)
                
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    Text("Using .dsLargeTitle()")
                        .dsLargeTitle()
                    
                    Text("Using .dsHeadline()")
                        .dsHeadline()
                    
                    Text("Using .dsBody()")
                        .dsBody()
                    
                    Text("Using .dsCaption1()")
                        .dsCaption1()
                }
                .padding()
                .background(DSColors.backgroundElevated)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
            }
            .padding()
        }
        .background(DSColors.neutral100)
        .navigationTitle("Typography")
    }
}

struct TypographyRow: View {
    let name: String
    let font: Font
    let specs: String
    let usage: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(name)
                .font(font)
                .foregroundColor(DSColors.textPrimary)
            
            Text("\(specs) • \(usage)")
                .font(DSTypography.caption1)
                .foregroundColor(DSColors.textTertiary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DSColors.backgroundElevated)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
    }
}

#Preview {
    NavigationStack {
        TypographyShowcase()
    }
}
