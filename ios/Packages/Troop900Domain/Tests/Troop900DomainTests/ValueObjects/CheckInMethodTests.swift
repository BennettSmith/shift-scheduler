import Testing
@testable import Troop900Domain

@Suite("CheckInMethod Tests")
struct CheckInMethodTests {
    
    @Test("Display names are correct")
    func displayNames() {
        #expect(CheckInMethod.qrCode.displayName == "QR Code")
        #expect(CheckInMethod.manual.displayName == "Manual")
        #expect(CheckInMethod.adminOverride.displayName == "Admin Override")
    }
    
    @Test("Raw values")
    func rawValues() {
        #expect(CheckInMethod.qrCode.rawValue == "qr_code")
        #expect(CheckInMethod.manual.rawValue == "manual")
        #expect(CheckInMethod.adminOverride.rawValue == "admin_override")
    }
}
