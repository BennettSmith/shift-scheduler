import XCTest
@testable import Troop900Bootstrap

final class BootstrapTests: XCTestCase {
    
    func testInMemoryDataContainerCreation() {
        // Test that we can create an in-memory data container
        let container = AppEnvironment.makeInMemoryDataContainer()
        XCTAssertNotNil(container)
    }
    
    func testInMemoryDataContainerWithInitialData() {
        // Test that we can create a container with initial data
        let initialData = InMemoryInitialData()
        let container = AppEnvironment.makeInMemoryDataContainer(initialData: initialData)
        XCTAssertNotNil(container)
    }
}
