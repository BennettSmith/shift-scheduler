import Foundation
import Testing
@testable import Troop900Domain

@Suite("ShiftTemplate Tests")
struct ShiftTemplateTests {
    
    @Test("ShiftTemplate initialization")
    func shiftTemplateInitialization() {
        let template = ShiftTemplate(
            id: "template-1",
            name: "Morning Shift",
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600 * 4),
            requiredScouts: 3,
            requiredParents: 2,
            location: "Tree Lot",
            label: "Morning",
            notes: "Bring coffee",
            isActive: true,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        #expect(template.id == "template-1")
        #expect(template.name == "Morning Shift")
        #expect(template.requiredScouts == 3)
        #expect(template.requiredParents == 2)
        #expect(template.location == "Tree Lot")
        #expect(template.isActive)
    }
}
