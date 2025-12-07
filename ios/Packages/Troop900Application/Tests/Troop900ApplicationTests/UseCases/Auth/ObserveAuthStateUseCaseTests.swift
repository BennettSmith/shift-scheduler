import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("ObserveAuthStateUseCase Tests")
struct ObserveAuthStateUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockAuthRepository = MockAuthRepository()
    
    private var useCase: ObserveAuthStateUseCase {
        ObserveAuthStateUseCase(authRepository: mockAuthRepository)
    }
    
    // MARK: - Stream Tests
    
    @Test("Observe auth state returns stream from repository")
    func observeAuthStateReturnsStream() async throws {
        // Given
        let expectedUserIds: [String?] = ["user-123", nil, "user-456"]
        mockAuthRepository.authStateValues = expectedUserIds
        
        // When
        let stream = useCase.execute()
        
        // Then - collect values from stream
        var receivedValues: [String?] = []
        for await userId in stream {
            receivedValues.append(userId)
            if receivedValues.count >= expectedUserIds.count {
                break
            }
        }
        
        #expect(receivedValues == expectedUserIds)
    }
    
    @Test("Observe auth state emits nil for signed out state")
    func observeAuthStateEmitsNilForSignedOut() async throws {
        // Given
        mockAuthRepository.authStateValues = [nil]
        
        // When
        let stream = useCase.execute()
        
        // Then
        var receivedValue: String?
        var didReceiveValue = false
        for await userId in stream {
            receivedValue = userId
            didReceiveValue = true
            break
        }
        
        #expect(didReceiveValue == true)
        #expect(receivedValue == nil)
    }
    
    @Test("Observe auth state emits user ID for signed in state")
    func observeAuthStateEmitsUserIdForSignedIn() async throws {
        // Given
        let expectedUserId = "user-789"
        mockAuthRepository.authStateValues = [expectedUserId]
        
        // When
        let stream = useCase.execute()
        
        // Then
        var receivedValue: String?
        for await userId in stream {
            receivedValue = userId
            break
        }
        
        #expect(receivedValue == expectedUserId)
    }
    
    @Test("Observe auth state tracks sign in and sign out transitions")
    func observeAuthStateTracksTransitions() async throws {
        // Given - simulate: signed out -> signed in -> signed out
        mockAuthRepository.authStateValues = [nil, "user-123", nil]
        
        // When
        let stream = useCase.execute()
        
        // Then
        var values: [String?] = []
        for await userId in stream {
            values.append(userId)
            if values.count >= 3 {
                break
            }
        }
        
        #expect(values.count == 3)
        #expect(values[0] == nil)       // Initially signed out
        #expect(values[1] == "user-123") // Signed in
        #expect(values[2] == nil)        // Signed out again
    }
}
