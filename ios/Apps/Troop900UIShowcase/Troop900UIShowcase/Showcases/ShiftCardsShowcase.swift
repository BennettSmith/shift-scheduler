//
//  ShiftCardsShowcase.swift
//  Troop900UIShowcase
//

import SwiftUI
import Troop900DesignSystem

struct ShiftCardsShowcase: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                
                // Shift Cards
                showcaseSection("Shift Cards") {
                    DSShiftCard(
                        time: "4:00 PM - 7:00 PM",
                        name: "Weekday Evening",
                        scoutCount: 1,
                        scoutRequired: 2,
                        parentCount: 1,
                        parentRequired: 2
                    ) { }
                    
                    DSShiftCard(
                        time: "9:00 AM - 1:00 PM",
                        name: "Saturday Morning",
                        scoutCount: 3,
                        scoutRequired: 3,
                        parentCount: 2,
                        parentRequired: 2,
                        isSignedUp: true
                    ) { }
                    
                    DSShiftCard(
                        time: "2:00 PM - 6:00 PM",
                        name: "Saturday Afternoon",
                        scoutCount: 0,
                        scoutRequired: 3,
                        parentCount: 1,
                        parentRequired: 2
                    ) { }
                }
                
                // Family Shift Cards
                showcaseSection("Family Shift Cards") {
                    DSFamilyShiftCard(
                        name: "Alex Smith",
                        personType: .scout,
                        time: "10:00 AM - 2:00 PM",
                        shiftName: "Morning Shift",
                        checkInStatus: .checkedIn(time: "9:58 AM")
                    )
                    
                    DSFamilyShiftCard(
                        name: "Sarah Smith",
                        personType: .parent,
                        time: "2:00 PM - 6:00 PM",
                        shiftName: "Afternoon Shift",
                        checkInStatus: .notCheckedIn
                    )
                    
                    DSFamilyShiftCard(
                        name: "Alex Smith",
                        personType: .scout,
                        time: "4:00 PM - 7:00 PM",
                        shiftName: "Weekday Evening",
                        checkInStatus: .notCheckedIn,
                        attribution: "Smith Household"
                    )
                }
                
                // Week Cards
                showcaseSection("Week Cards") {
                    DSWeekCard(
                        weekNumber: 1,
                        dateRange: "Nov 25 - Dec 1",
                        totalShifts: 12,
                        needsCoverage: 3,
                        signedUp: 2
                    ) { }
                    
                    DSWeekCard(
                        weekNumber: 2,
                        dateRange: "Dec 2 - Dec 8",
                        totalShifts: 14,
                        needsCoverage: 0,
                        signedUp: 1
                    ) { }
                    
                    DSWeekCard(
                        weekNumber: 3,
                        dateRange: "Dec 9 - Dec 15",
                        totalShifts: 14,
                        needsCoverage: 5,
                        signedUp: 0
                    ) { }
                }
                
                // Current Shift Cards
                showcaseSection("Current/Next Shift Cards") {
                    DSCurrentShiftCard(
                        name: "Saturday Morning",
                        time: "9:00 AM - 1:00 PM",
                        state: .current(startedMinutesAgo: 47)
                    )
                    
                    DSCurrentShiftCard(
                        name: "Saturday Afternoon",
                        time: "2:00 PM - 6:00 PM",
                        state: .upcoming(startsIn: "2 hours 15 min")
                    )
                }
                
                // Shift Info Header
                showcaseSection("Shift Info Header") {
                    DSCard {
                        DSShiftInfoHeader(
                            name: "Saturday Morning",
                            date: "Saturday, Nov 30",
                            time: "9:00 AM - 1:00 PM",
                            location: "Tree Lot - Main Entrance"
                        )
                    }
                }
            }
            .padding()
        }
        .background(DSColors.neutral100)
        .navigationTitle("Shift Cards")
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
        ShiftCardsShowcase()
    }
}
