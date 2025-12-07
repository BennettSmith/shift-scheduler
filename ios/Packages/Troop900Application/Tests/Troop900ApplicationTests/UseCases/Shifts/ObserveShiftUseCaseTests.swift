import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("ObserveShiftUseCase Tests")
struct ObserveShiftUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockShiftRepository = MockShiftRepository()
    
    private var useCase: ObserveShiftUseCase {
        ObserveShiftUseCase(shiftRepository: mockShiftRepository)
    }
    
    // MARK: - Stream Tests
    
    @Test("Observe shift returns stream from repository")
    func observeShiftReturnsStream() async throws {
        // Given
        let shiftId = "shift-1"
        let shift = TestFixtures.createShift(id: shiftId, label: "Test Shift")
        mockShiftRepository.shiftsById[shiftId] = shift
        
        // When
        let stream = useCase.execute(shiftId: shiftId)
        
        // Then - collect first value from stream
        var receivedShift: Shift?
        for try await value in stream {
            receivedShift = value
            break
        }
        
        #expect(receivedShift != nil)
        #expect(receivedShift?.id == shiftId)
        #expect(receivedShift?.label == "Test Shift")
    }
    
    @Test("Observe shift emits shift data")
    func observeShiftEmitsShiftData() async throws {
        // Given
        let shiftId = "shift-1"
        let shift = TestFixtures.createShift(
            id: shiftId,
            requiredScouts: 4,
            requiredParents: 2,
            currentScouts: 2,
            currentParents: 1,
            location: "Tree Lot A",
            status: .published
        )
        mockShiftRepository.shiftsById[shiftId] = shift
        
        // When
        let stream = useCase.execute(shiftId: shiftId)
        
        // Then
        var receivedShift: Shift?
        for try await value in stream {
            receivedShift = value
            break
        }
        
        #expect(receivedShift?.requiredScouts == 4)
        #expect(receivedShift?.requiredParents == 2)
        #expect(receivedShift?.currentScouts == 2)
        #expect(receivedShift?.currentParents == 1)
        #expect(receivedShift?.location == "Tree Lot A")
        #expect(receivedShift?.status == .published)
    }
}
