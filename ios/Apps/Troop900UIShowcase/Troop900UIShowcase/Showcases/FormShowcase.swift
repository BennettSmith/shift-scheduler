//
//  FormShowcase.swift
//  Troop900UIShowcase
//

import SwiftUI
import Troop900DesignSystem

struct FormShowcase: View {
    @State private var textFieldValue = ""
    @State private var textFieldWithError = ""
    @State private var textAreaValue = ""
    @State private var searchValue = ""
    @State private var pushNotificationsEnabled = true
    @State private var shiftRemindersEnabled = true
    @State private var scoutsRequired = 3
    @State private var parentsRequired = 2
    @State private var selectedRadio = "Option 1"
    @State private var weekdayEveningChecked = false
    @State private var weekendMorningChecked = true
    @State private var selectedPerson = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                
                // Text Fields
                showcaseSection("Text Fields") {
                    DSTextField(
                        label: "Shift Name",
                        placeholder: "Enter shift name",
                        text: $textFieldValue
                    )
                    
                    DSTextField(
                        label: "Email",
                        placeholder: "email@example.com",
                        text: $textFieldWithError,
                        isRequired: true,
                        errorMessage: textFieldWithError.isEmpty ? "Email is required" : nil
                    )
                }
                
                // Text Area
                showcaseSection("Text Area") {
                    DSTextArea(
                        label: "Notes (optional)",
                        placeholder: "Add a note about your shift...",
                        text: $textAreaValue
                    )
                }
                
                // Search Field
                showcaseSection("Search Field") {
                    DSSearchField(
                        placeholder: "Search by name...",
                        text: $searchValue
                    )
                }
                
                // Toggle Row
                showcaseSection("Toggle Rows") {
                    DSCard {
                        VStack(spacing: 0) {
                            DSToggleRow(
                                title: "Push Notifications",
                                isOn: $pushNotificationsEnabled
                            )
                            Divider()
                            DSToggleRow(
                                title: "Shift Reminders",
                                subtitle: "1 hour before shift",
                                isOn: $shiftRemindersEnabled
                            )
                        }
                    }
                }
                
                // Stepper Row
                showcaseSection("Stepper Rows") {
                    DSCard {
                        VStack(spacing: 0) {
                            DSStepperRow(
                                title: "Scouts Required",
                                icon: .scout,
                                value: $scoutsRequired,
                                range: 1...10
                            )
                            Divider()
                            DSStepperRow(
                                title: "Parents Required",
                                icon: .people,
                                value: $parentsRequired,
                                range: 1...10
                            )
                        }
                    }
                }
                
                // Radio Buttons
                showcaseSection("Radio Buttons") {
                    DSCard {
                        VStack(alignment: .leading, spacing: DSSpacing.sm) {
                            DSRadioButton(
                                title: "All Families",
                                isSelected: selectedRadio == "Option 1"
                            ) { selectedRadio = "Option 1" }
                            
                            DSRadioButton(
                                title: "Parents Only",
                                isSelected: selectedRadio == "Option 2"
                            ) { selectedRadio = "Option 2" }
                            
                            DSRadioButton(
                                title: "Scouts Only",
                                subtitle: "With their own accounts",
                                isSelected: selectedRadio == "Option 3"
                            ) { selectedRadio = "Option 3" }
                        }
                    }
                }
                
                // Checkbox
                showcaseSection("Checkboxes") {
                    DSCard {
                        VStack(alignment: .leading, spacing: DSSpacing.sm) {
                            DSCheckbox(
                                title: "Weekday Evening",
                                subtitle: "Mon-Thu 4:00 PM - 7:00 PM",
                                isChecked: $weekdayEveningChecked
                            )
                            DSCheckbox(
                                title: "Weekend Morning",
                                subtitle: "Sat-Sun 9:00 AM - 1:00 PM",
                                isChecked: $weekendMorningChecked
                            )
                        }
                    }
                }
                
                // Selection Rows
                showcaseSection("Selection Rows") {
                    VStack(spacing: DSSpacing.sm) {
                        DSSelectionRow(
                            title: "Sarah Smith (me)",
                            trailingText: "Parent",
                            isSelected: selectedPerson == 0
                        ) { selectedPerson = 0 }
                        
                        DSSelectionRow(
                            title: "Alex Smith",
                            trailingText: "Scout",
                            isSelected: selectedPerson == 1
                        ) { selectedPerson = 1 }
                        
                        DSSelectionRow(
                            title: "Emma Smith",
                            subtitle: "Already signed up",
                            trailingText: "Scout",
                            isSelected: false,
                            isDisabled: true
                        ) { }
                    }
                }
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        .background(DSColors.neutral100)
        .onTapGesture {
            hideKeyboard()
        }
        .navigationTitle("Form Components")
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
        FormShowcase()
    }
}
