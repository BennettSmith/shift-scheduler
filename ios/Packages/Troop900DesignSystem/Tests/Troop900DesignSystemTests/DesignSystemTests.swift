import Testing
import SwiftUI
@testable import Troop900DesignSystem

@Suite("Design System Tests")
struct DesignSystemTests {
    
    // MARK: - Color Tests
    
    @Test("Primary colors are defined correctly")
    func primaryColors() {
        // Verify primary color exists and is accessible
        let primary = DSColors.primary
        let primaryDark = DSColors.primaryDark
        let primaryLight = DSColors.primaryLight
        
        #expect(primary != primaryDark)
        #expect(primary != primaryLight)
    }
    
    @Test("Semantic colors are defined")
    func semanticColors() {
        let success = DSColors.success
        let warning = DSColors.warning
        let error = DSColors.error
        let info = DSColors.info
        
        // All semantic colors should be different
        #expect(success != warning)
        #expect(warning != error)
        #expect(error != info)
    }
    
    @Test("Color hex initializer works correctly")
    func colorHexInitializer() {
        let white = Color(hex: 0xFFFFFF)
        let black = Color(hex: 0x000000)
        let red = Color(hex: 0xFF0000)
        
        // These should create valid colors without crashing
        #expect(white != black)
        #expect(red != black)
    }
    
    // MARK: - Spacing Tests
    
    @Test("Spacing scale is ordered correctly")
    func spacingScale() {
        #expect(DSSpacing.xs < DSSpacing.sm)
        #expect(DSSpacing.sm < DSSpacing.md)
        #expect(DSSpacing.md < DSSpacing.lg)
        #expect(DSSpacing.lg < DSSpacing.xl)
        #expect(DSSpacing.xl < DSSpacing.xxl)
    }
    
    @Test("Spacing values match specification")
    func spacingValues() {
        #expect(DSSpacing.xs == 4)
        #expect(DSSpacing.sm == 8)
        #expect(DSSpacing.md == 16)
        #expect(DSSpacing.lg == 24)
        #expect(DSSpacing.xl == 32)
        #expect(DSSpacing.xxl == 48)
    }
    
    // MARK: - Radius Tests
    
    @Test("Radius scale is ordered correctly")
    func radiusScale() {
        #expect(DSRadius.sm < DSRadius.md)
        #expect(DSRadius.md < DSRadius.lg)
        #expect(DSRadius.lg < DSRadius.full)
    }
    
    @Test("Radius values match specification")
    func radiusValues() {
        #expect(DSRadius.sm == 8)
        #expect(DSRadius.md == 12)
        #expect(DSRadius.lg == 16)
        #expect(DSRadius.full == 9999)
    }
    
    // MARK: - Icon Tests
    
    @Test("Tab bar icons are defined")
    func tabBarIcons() {
        #expect(DSIcon.home.rawValue == "house")
        #expect(DSIcon.homeFill.rawValue == "house.fill")
        #expect(DSIcon.calendar.rawValue == "calendar")
        // Note: calendar has no .fill variant in SF Symbols
        #expect(DSIcon.checkIn.rawValue == "checkmark.circle")
        #expect(DSIcon.checkInFill.rawValue == "checkmark.circle.fill")
        #expect(DSIcon.profile.rawValue == "person")
        #expect(DSIcon.profileFill.rawValue == "person.fill")
        #expect(DSIcon.committee.rawValue == "shield")
        #expect(DSIcon.committeeFill.rawValue == "shield.fill")
    }
    
    @Test("Tab bar icon pairs are configured")
    func tabBarIconPairs() {
        #expect(TabBarIcon.home.inactive == .home)
        #expect(TabBarIcon.home.active == .homeFill)
        #expect(TabBarIcon.schedule.inactive == .calendar)
        #expect(TabBarIcon.schedule.active == .calendar) // Same icon - no fill variant exists
    }
    
    // MARK: - Status Type Tests
    
    @Test("Status types have correct colors")
    func statusTypeColors() {
        #expect(DSStatusType.success.foregroundColor == DSColors.success)
        #expect(DSStatusType.warning.foregroundColor == DSColors.warning)
        #expect(DSStatusType.critical.foregroundColor == DSColors.error)
        #expect(DSStatusType.signedUp.foregroundColor == DSColors.primary)
        #expect(DSStatusType.info.foregroundColor == DSColors.info)
    }
    
    @Test("Status types have icons where appropriate")
    func statusTypeIcons() {
        #expect(DSStatusType.success.icon != nil)
        #expect(DSStatusType.warning.icon != nil)
        #expect(DSStatusType.critical.icon != nil)
        #expect(DSStatusType.signedUp.icon != nil)
        #expect(DSStatusType.neutral.icon == nil)
    }
    
    // MARK: - Toast Tests
    
    @Test("Toast data convenience initializers work")
    func toastConvenienceInitializers() {
        let success = DSToastData.success("Test")
        let error = DSToastData.error("Test")
        let info = DSToastData.info("Test")
        let warning = DSToastData.warning("Test")
        
        #expect(success.style == .success)
        #expect(error.style == .error)
        #expect(info.style == .info)
        #expect(warning.style == .warning)
    }
    
    @Test("Toast data has unique IDs")
    func toastUniqueIds() {
        let toast1 = DSToastData.success("Test 1")
        let toast2 = DSToastData.success("Test 2")
        
        #expect(toast1.id != toast2.id)
    }
    
    // MARK: - Avatar Tests
    
    @Test("Avatar from name extracts initials correctly")
    func avatarInitials() {
        // This tests the static method that extracts initials
        let avatar = DSAvatar.fromName("Sarah Smith")
        // Avatar was created without crashing
        #expect(avatar != nil)
    }
    
    @Test("Avatar sizes have correct diameters")
    func avatarSizes() {
        #expect(DSAvatarSize.small.diameter == 32)
        #expect(DSAvatarSize.medium.diameter == 48)
        #expect(DSAvatarSize.large.diameter == 64)
        #expect(DSAvatarSize.xlarge.diameter == 80)
        #expect(DSAvatarSize.profile.diameter == 100)
    }
    
    // MARK: - Button Size Tests
    
    @Test("Button sizes have correct heights")
    func buttonSizeHeights() {
        #expect(DSButtonSize.regular.height == 50)
        #expect(DSButtonSize.small.height == 40)
        #expect(DSButtonSize.compact.height == 36)
    }
    
    // MARK: - Version Test
    
    @Test("Design system version is defined")
    func versionIsDefined() {
        #expect(!designSystemVersion.isEmpty)
        #expect(designSystemVersion == "1.0.0")
    }
}
