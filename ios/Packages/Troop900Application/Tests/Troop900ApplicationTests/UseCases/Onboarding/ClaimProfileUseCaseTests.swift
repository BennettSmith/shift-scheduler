import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("ClaimProfileUseCase Tests")
struct ClaimProfileUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockOnboardingService = MockOnboardingService()
    private let mockUserRepository = MockUserRepository()
    
    private var useCase: ClaimProfileUseCase {
        ClaimProfileUseCase(
            onboardingService: mockOnboardingService,
            userRepository: mockUserRepository
        )
    }
    
    // MARK: - Success Tests
    
    @Test("Claim profile succeeds and returns user")
    func claimProfileSucceedsAndReturnsUser() async throws {
        // Given
        let claimCode = "CLAIM-ABC123"
        let userId = "user-123"
        let claimedUser = TestFixtures.createUser(
            id: userId,
            firstName: "John",
            lastName: "Smith",
            isClaimed: true
        )
        
        mockOnboardingService.claimProfileResult = .success(ClaimProfileResult(
            success: true,
            userId: userId,
            message: "Profile claimed successfully"
        ))
        mockUserRepository.usersById[userId] = claimedUser
        
        let request = ClaimProfileRequest(claimCode: claimCode, userId: userId)
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == true)
        #expect(response.user?.id == userId)
        #expect(response.user?.firstName == "John")
        #expect(response.user?.lastName == "Smith")
        #expect(response.user?.isClaimed == true)
        #expect(response.message == "Profile claimed successfully")
        #expect(mockOnboardingService.claimProfileCallCount == 1)
        #expect(mockOnboardingService.claimProfileCalledWith[0].claimCode == claimCode)
        #expect(mockOnboardingService.claimProfileCalledWith[0].userId == userId)
    }
    
    @Test("Claim profile succeeds for scout profile")
    func claimProfileSucceedsForScout() async throws {
        // Given
        let claimCode = "SCOUT-CLAIM-789"
        let userId = "scout-456"
        let scoutUser = TestFixtures.createScout(
            id: userId,
            firstName: "Tommy",
            lastName: "Jones",
            isClaimed: true
        )
        
        mockOnboardingService.claimProfileResult = .success(ClaimProfileResult(
            success: true,
            userId: userId,
            message: "Scout profile linked!"
        ))
        mockUserRepository.usersById[userId] = scoutUser
        
        let request = ClaimProfileRequest(claimCode: claimCode, userId: userId)
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == true)
        #expect(response.user?.role == .scout)
        #expect(response.user?.isClaimed == true)
    }
    
    @Test("Claim profile handles user fetch failure gracefully")
    func claimProfileHandlesUserFetchFailure() async throws {
        // Given
        let claimCode = "CLAIM-ABC123"
        let userId = "user-123"
        
        mockOnboardingService.claimProfileResult = .success(ClaimProfileResult(
            success: true,
            userId: userId,
            message: "Profile claimed"
        ))
        // User not in repository - getUser will throw DomainError.userNotFound
        // Use case handles this with try? so it becomes nil
        
        let request = ClaimProfileRequest(claimCode: claimCode, userId: userId)
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == true)
        #expect(response.user == nil) // User fetch threw error, caught by try?
        #expect(response.message == "Profile claimed")
        #expect(mockUserRepository.getUserCallCount == 1) // Verify fetch was attempted
        #expect(mockUserRepository.getUserCalledWith[0] == userId)
    }
    
    // MARK: - Failure Tests
    
    @Test("Claim profile returns failure for invalid claim code")
    func claimProfileFailsForInvalidCode() async throws {
        // Given
        let claimCode = "INVALID-CODE"
        let userId = "user-123"
        
        mockOnboardingService.claimProfileResult = .success(ClaimProfileResult(
            success: false,
            userId: nil,
            message: "Invalid claim code"
        ))
        
        let request = ClaimProfileRequest(claimCode: claimCode, userId: userId)
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == false)
        #expect(response.user == nil)
        #expect(response.message == "Invalid claim code")
    }
    
    @Test("Claim profile returns failure when profile already claimed")
    func claimProfileFailsWhenAlreadyClaimed() async throws {
        // Given
        let claimCode = "ALREADY-CLAIMED"
        let userId = "user-123"
        
        mockOnboardingService.claimProfileResult = .success(ClaimProfileResult(
            success: false,
            userId: nil,
            message: "This profile has already been claimed"
        ))
        
        let request = ClaimProfileRequest(claimCode: claimCode, userId: userId)
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == false)
        #expect(response.message == "This profile has already been claimed")
    }
    
    @Test("Claim profile does not fetch user when service returns failure")
    func claimProfileDoesNotFetchUserOnFailure() async throws {
        // Given
        let claimCode = "INVALID"
        let userId = "user-123"
        
        mockOnboardingService.claimProfileResult = .success(ClaimProfileResult(
            success: false,
            userId: nil,
            message: "Failed"
        ))
        
        let request = ClaimProfileRequest(claimCode: claimCode, userId: userId)
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == false)
        #expect(response.user == nil)
        #expect(mockUserRepository.getUserCallCount == 0) // Should not fetch user
    }
    
    // MARK: - Error Tests
    
    @Test("Claim profile throws when service fails")
    func claimProfileThrowsWhenServiceFails() async throws {
        // Given
        let claimCode = "ANY-CODE"
        let userId = "user-123"
        
        mockOnboardingService.claimProfileResult = .failure(DomainError.networkError)
        
        let request = ClaimProfileRequest(claimCode: claimCode, userId: userId)
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Claim profile throws for unauthorized access")
    func claimProfileThrowsForUnauthorized() async throws {
        // Given
        let claimCode = "CLAIM-CODE"
        let userId = "user-123"
        
        mockOnboardingService.claimProfileResult = .failure(DomainError.unauthorized)
        
        let request = ClaimProfileRequest(claimCode: claimCode, userId: userId)
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
}
