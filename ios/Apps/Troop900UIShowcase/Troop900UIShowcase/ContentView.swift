//
//  ContentView.swift
//  Troop900UIShowcase
//
//  Created by Bennett Smith on 12/6/25.
//

import SwiftUI
import Troop900DesignSystem

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Design Tokens") {
                    NavigationLink("Colors", destination: ColorsShowcase())
                    NavigationLink("Typography", destination: TypographyShowcase())
                    NavigationLink("Spacing & Radius", destination: SpacingShowcase())
                    NavigationLink("Icons", destination: IconsShowcase())
                }
                
                Section("Buttons") {
                    NavigationLink("Buttons", destination: ButtonsShowcase())
                }
                
                Section("Cards & Containers") {
                    NavigationLink("Cards", destination: CardsShowcase())
                    NavigationLink("Shift Cards", destination: ShiftCardsShowcase())
                }
                
                Section("Status & Badges") {
                    NavigationLink("Status Badges", destination: StatusBadgesShowcase())
                }
                
                Section("Form Components") {
                    NavigationLink("Form Inputs", destination: FormShowcase())
                }
                
                Section("Lists & Rows") {
                    NavigationLink("List Components", destination: ListShowcase())
                }
                
                Section("Feedback & State") {
                    NavigationLink("Empty States", destination: EmptyStatesShowcase())
                    NavigationLink("Loading States", destination: LoadingShowcase())
                    NavigationLink("Toasts", destination: ToastShowcase())
                    NavigationLink("Offline States", destination: OfflineShowcase())
                }
                
                Section("Sheets & Dialogs") {
                    NavigationLink("Sheet Components", destination: SheetsShowcase())
                }
                
                Section("Profile & Stats") {
                    NavigationLink("Avatars & Profile", destination: AvatarShowcase())
                    NavigationLink("Hours & Stats", destination: StatsShowcase())
                }
            }
            .navigationTitle("Design System")
        }
    }
}

#Preview {
    ContentView()
}
