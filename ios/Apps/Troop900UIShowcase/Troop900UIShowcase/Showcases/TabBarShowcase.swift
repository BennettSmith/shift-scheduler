//
//  TabBarShowcase.swift
//  Troop900UIShowcase
//

import SwiftUI
import Troop900DesignSystem

struct TabBarShowcase: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Content area
            TabView(selection: $selectedTab) {
                tabContent("Home", icon: .home)
                    .tag(0)
                
                tabContent("Schedule", icon: .calendar)
                    .tag(1)
                
                tabContent("Check-In", icon: .checkIn)
                    .tag(2)
                
                tabContent("Profile", icon: .profile)
                    .tag(3)
                
                tabContent("Committee", icon: .committee)
                    .tag(4)
            }
            .tabViewStyle(.automatic)
            .tint(DSColors.primary)
        }
        .navigationTitle("Tab Bar Demo")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func tabContent(_ title: String, icon: DSIcon) -> some View {
        VStack(spacing: DSSpacing.lg) {
            DSIconView(icon, size: .custom(64), color: DSColors.primary)
            
            Text(title)
                .font(DSTypography.title1)
                .foregroundColor(DSColors.textPrimary)
            
            Text("This is the \(title) tab")
                .font(DSTypography.body)
                .foregroundColor(DSColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DSColors.backgroundPage)
        .tabItem {
            Label(title, systemImage: icon.rawValue)
        }
    }
}

#Preview {
    NavigationStack {
        TabBarShowcase()
    }
}
