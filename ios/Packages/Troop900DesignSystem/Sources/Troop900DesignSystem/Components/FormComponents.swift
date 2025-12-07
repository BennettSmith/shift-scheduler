import SwiftUI

// MARK: - Design System Form Components
// Based on Troop 900 iOS UI Design Specification

/// A styled text input field.
public struct DSTextField: View {
    private let label: String
    private let placeholder: String
    @Binding private var text: String
    private let isRequired: Bool
    private let errorMessage: String?
    
    public init(
        label: String,
        placeholder: String = "",
        text: Binding<String>,
        isRequired: Bool = false,
        errorMessage: String? = nil
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.isRequired = isRequired
        self.errorMessage = errorMessage
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack(spacing: DSSpacing.xs) {
                Text(label)
                    .font(DSTypography.subhead)
                    .foregroundColor(DSColors.textSecondary)
                
                if isRequired {
                    Text("*")
                        .font(DSTypography.subhead)
                        .foregroundColor(DSColors.error)
                }
            }
            
            TextField(placeholder, text: $text)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textPrimary)
                .padding(DSSpacing.md)
                .background(DSColors.backgroundElevated)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.md)
                        .stroke(errorMessage != nil ? DSColors.error : DSColors.neutral200, lineWidth: 1)
                )
            
            if let error = errorMessage {
                Text(error)
                    .font(DSTypography.caption1)
                    .foregroundColor(DSColors.error)
            }
        }
    }
}

// MARK: - Text Area

/// A multi-line text input field.
public struct DSTextArea: View {
    private let label: String
    private let placeholder: String
    @Binding private var text: String
    private let minHeight: CGFloat
    
    public init(
        label: String,
        placeholder: String = "",
        text: Binding<String>,
        minHeight: CGFloat = 100
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.minHeight = minHeight
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(label)
                .font(DSTypography.subhead)
                .foregroundColor(DSColors.textSecondary)
            
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(DSTypography.body)
                        .foregroundColor(DSColors.textTertiary)
                        .padding(DSSpacing.md)
                        .padding(.top, 2)
                }
                
                TextEditor(text: $text)
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .padding(DSSpacing.sm)
                    .frame(minHeight: minHeight)
            }
            .background(DSColors.backgroundElevated)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .stroke(DSColors.neutral200, lineWidth: 1)
            )
        }
    }
}

// MARK: - Search Field

/// A search input field with magnifying glass icon.
public struct DSSearchField: View {
    private let placeholder: String
    @Binding private var text: String
    
    public init(placeholder: String = "Search...", text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }
    
    public var body: some View {
        HStack(spacing: DSSpacing.sm) {
            DSIconView(.search, size: .medium, color: DSColors.textTertiary)
            
            TextField(placeholder, text: $text)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textPrimary)
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    DSIconView(.close, size: .small, color: DSColors.textTertiary)
                }
            }
        }
        .padding(DSSpacing.md)
        .background(DSColors.backgroundElevated)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DSRadius.md)
                .stroke(DSColors.neutral200, lineWidth: 1)
        )
    }
}

// MARK: - Toggle Row

/// A row with a label and toggle switch.
public struct DSToggleRow: View {
    private let title: String
    private let subtitle: String?
    @Binding private var isOn: Bool
    
    public init(title: String, subtitle: String? = nil, isOn: Binding<Bool>) {
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
    }
    
    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(title)
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(DSTypography.caption1)
                        .foregroundColor(DSColors.textTertiary)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(DSColors.primary)
                .labelsHidden()
        }
        .padding(.vertical, DSSpacing.sm)
    }
}

// MARK: - Stepper Row

/// A row with a label and stepper control.
public struct DSStepperRow: View {
    private let title: String
    private let icon: DSIcon?
    @Binding private var value: Int
    private let range: ClosedRange<Int>
    
    public init(
        title: String,
        icon: DSIcon? = nil,
        value: Binding<Int>,
        range: ClosedRange<Int> = 1...10
    ) {
        self.title = title
        self.icon = icon
        self._value = value
        self.range = range
    }
    
    public var body: some View {
        HStack {
            if let icon = icon {
                DSIconView(icon, size: .medium, color: DSColors.textSecondary)
            }
            
            Text(title)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textPrimary)
            
            Spacer()
            
            HStack(spacing: DSSpacing.sm) {
                Button {
                    if value > range.lowerBound {
                        value -= 1
                    }
                } label: {
                    Text("−")
                        .font(DSTypography.title3)
                        .foregroundColor(value > range.lowerBound ? DSColors.primary : DSColors.neutral300)
                        .frame(width: 36, height: 36)
                        .background(DSColors.neutral100)
                        .clipShape(Circle())
                }
                .disabled(value <= range.lowerBound)
                
                Text("\(value)")
                    .font(DSTypography.headline)
                    .foregroundColor(DSColors.textPrimary)
                    .frame(minWidth: 32)
                
                Button {
                    if value < range.upperBound {
                        value += 1
                    }
                } label: {
                    Text("+")
                        .font(DSTypography.title3)
                        .foregroundColor(value < range.upperBound ? DSColors.primary : DSColors.neutral300)
                        .frame(width: 36, height: 36)
                        .background(DSColors.neutral100)
                        .clipShape(Circle())
                }
                .disabled(value >= range.upperBound)
            }
        }
        .padding(.vertical, DSSpacing.sm)
    }
}

// MARK: - Radio Button Group

/// A group of radio button options.
public struct DSRadioGroup<T: Hashable & CustomStringConvertible>: View {
    private let options: [T]
    @Binding private var selection: T
    
    public init(options: [T], selection: Binding<T>) {
        self.options = options
        self._selection = selection
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            ForEach(options, id: \.self) { option in
                DSRadioButton(
                    title: option.description,
                    isSelected: selection == option
                ) {
                    selection = option
                }
            }
        }
    }
}

/// A single radio button.
public struct DSRadioButton: View {
    private let title: String
    private let subtitle: String?
    private let isSelected: Bool
    private let action: () -> Void
    
    public init(
        title: String,
        subtitle: String? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.md) {
                Circle()
                    .stroke(isSelected ? DSColors.primary : DSColors.neutral300, lineWidth: 2)
                    .frame(width: 22, height: 22)
                    .overlay(
                        Circle()
                            .fill(isSelected ? DSColors.primary : Color.clear)
                            .frame(width: 12, height: 12)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(DSTypography.body)
                        .foregroundColor(DSColors.textPrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(DSTypography.caption1)
                            .foregroundColor(DSColors.textTertiary)
                    }
                }
                
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, DSSpacing.xs)
    }
}

// MARK: - Checkbox

/// A checkbox control.
public struct DSCheckbox: View {
    private let title: String
    private let subtitle: String?
    @Binding private var isChecked: Bool
    
    public init(title: String, subtitle: String? = nil, isChecked: Binding<Bool>) {
        self.title = title
        self.subtitle = subtitle
        self._isChecked = isChecked
    }
    
    public var body: some View {
        Button {
            isChecked.toggle()
        } label: {
            HStack(spacing: DSSpacing.md) {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isChecked ? DSColors.primary : DSColors.neutral300, lineWidth: 2)
                    .frame(width: 22, height: 22)
                    .overlay(
                        Group {
                            if isChecked {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(DSColors.primary)
                            }
                        }
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(DSTypography.body)
                        .foregroundColor(DSColors.textPrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(DSTypography.caption1)
                            .foregroundColor(DSColors.textTertiary)
                    }
                }
                
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, DSSpacing.xs)
    }
}

// MARK: - Selection Row (for multi-select lists)

/// A selectable row for use in lists (like person selection).
public struct DSSelectionRow: View {
    private let title: String
    private let subtitle: String?
    private let trailingText: String?
    private let isSelected: Bool
    private let isDisabled: Bool
    private let action: () -> Void
    
    public init(
        title: String,
        subtitle: String? = nil,
        trailingText: String? = nil,
        isSelected: Bool,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.trailingText = trailingText
        self.isSelected = isSelected
        self.isDisabled = isDisabled
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.md) {
                Circle()
                    .stroke(isSelected ? DSColors.primary : DSColors.neutral300, lineWidth: 2)
                    .frame(width: 22, height: 22)
                    .overlay(
                        Circle()
                            .fill(isSelected ? DSColors.primary : Color.clear)
                            .frame(width: 12, height: 12)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(DSTypography.body)
                        .foregroundColor(isDisabled ? DSColors.textTertiary : DSColors.textPrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(DSTypography.caption1)
                            .foregroundColor(DSColors.textTertiary)
                    }
                }
                
                Spacer()
                
                if let trailing = trailingText {
                    DSRoleBadge(DSRoleBadge.Role(rawValue: trailing) ?? .parent)
                }
            }
            .padding(DSSpacing.md)
            .background(isSelected ? DSColors.primaryLight : DSColors.backgroundElevated)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
            .opacity(isDisabled ? 0.6 : 1.0)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

// MARK: - Segmented Control

/// A styled segmented control.
public struct DSSegmentedControl<T: Hashable & CaseIterable & CustomStringConvertible>: View where T.AllCases: RandomAccessCollection {
    @Binding private var selection: T
    
    public init(selection: Binding<T>) {
        self._selection = selection
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(T.allCases), id: \.self) { option in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selection = option
                    }
                } label: {
                    Text(option.description)
                        .font(DSTypography.subhead)
                        .foregroundColor(selection == option ? DSColors.textOnPrimary : DSColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DSSpacing.sm)
                        .background(selection == option ? DSColors.primary : Color.clear)
                }
            }
        }
        .background(DSColors.neutral100)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
    }
}

// MARK: - Previews

#if DEBUG
struct DSFormComponents_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var text = ""
        @State private var notes = ""
        @State private var searchText = ""
        @State private var toggleOn = true
        @State private var count = 3
        @State private var selectedOption = "Option 1"
        @State private var isChecked = false
        @State private var selectedPerson = 0
        
        var body: some View {
            ScrollView {
                VStack(spacing: DSSpacing.lg) {
                    DSTextField(label: "Shift Name", placeholder: "Enter shift name", text: $text)
                    
                    DSTextField(label: "Email", placeholder: "email@example.com", text: $text, isRequired: true, errorMessage: text.isEmpty ? "Email is required" : nil)
                    
                    DSTextArea(label: "Notes (optional)", placeholder: "Add a note...", text: $notes)
                    
                    DSSearchField(placeholder: "Search by name...", text: $searchText)
                    
                    Divider()
                    
                    DSToggleRow(title: "Push Notifications", subtitle: "Receive shift reminders", isOn: $toggleOn)
                    
                    DSStepperRow(title: "Scouts Required", icon: .scout, value: $count)
                    
                    Divider()
                    
                    DSRadioButton(title: "Option 1", isSelected: selectedOption == "Option 1") {
                        selectedOption = "Option 1"
                    }
                    DSRadioButton(title: "Option 2", subtitle: "With a subtitle", isSelected: selectedOption == "Option 2") {
                        selectedOption = "Option 2"
                    }
                    
                    Divider()
                    
                    DSCheckbox(title: "I agree to the terms", isChecked: $isChecked)
                    
                    Divider()
                    
                    DSSelectionRow(title: "Sarah Smith (me)", trailingText: "Parent", isSelected: selectedPerson == 0) {
                        selectedPerson = 0
                    }
                    DSSelectionRow(title: "Alex Smith", trailingText: "Scout", isSelected: selectedPerson == 1) {
                        selectedPerson = 1
                    }
                    DSSelectionRow(title: "Emma Smith", subtitle: "Already signed up", trailingText: "Scout", isSelected: false, isDisabled: true) { }
                }
                .padding()
            }
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}
#endif
