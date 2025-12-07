import Testing
import Foundation
@testable import Troop900Domain

@Suite("StaffingStatus Tests")
struct StaffingStatusTests {
    
    @Test("Display names are correct")
    func displayNames() {
        #expect(StaffingStatus.empty.displayName == "Empty")
        #expect(StaffingStatus.partial.displayName == "Partially Staffed")
        #expect(StaffingStatus.full.displayName == "Fully Staffed")
    }
    
    @Test("Color names are correct")
    func colorNames() {
        #expect(StaffingStatus.empty.colorName == "red")
        #expect(StaffingStatus.partial.colorName == "yellow")
        #expect(StaffingStatus.full.colorName == "green")
    }
    
    @Test("Codable conformance")
    func codableConformance() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let empty = StaffingStatus.empty
        let data = try encoder.encode(empty)
        let decoded = try decoder.decode(StaffingStatus.self, from: data)
        
        #expect(decoded == empty)
    }
}
