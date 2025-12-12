import Foundation
import Testing
@testable import Troop900Domain

@Suite("Season Tests")
struct SeasonTests {
    
    @Test("Season initialization")
    func seasonInitialization() {
        let season = Season(
            id: "season-1",
            name: "2024 Tree Lot",
            year: 2024,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 30),
            status: .active,
            description: "Holiday season 2024",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        #expect(season.id == "season-1")
        #expect(season.name == "2024 Tree Lot")
        #expect(season.year == 2024)
        #expect(season.status == .active)
    }
    
    @Test("Active season reports as active")
    func activeSeasonIsActive() {
        let season = Season(
            id: "season-1",
            name: "2024 Tree Lot",
            year: 2024,
            startDate: Date(),
            endDate: Date(),
            status: .active,
            description: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        #expect(season.isActive)
    }
    
    @Test("Draft season is not active")
    func draftSeasonIsNotActive() {
        let season = Season(
            id: "season-1",
            name: "2024 Tree Lot",
            year: 2024,
            startDate: Date(),
            endDate: Date(),
            status: .draft,
            description: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        #expect(!season.isActive)
    }
}
