import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("UpdateProfilePhotoUseCase Tests")
struct UpdateProfilePhotoUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockUserRepository = MockUserRepository()
    
    private var useCase: UpdateProfilePhotoUseCase {
        UpdateProfilePhotoUseCase(userRepository: mockUserRepository)
    }
    
    // MARK: - Success Tests
    
    @Test("Update profile photo succeeds with valid JPEG")
    func updateProfilePhotoSucceedsWithJpeg() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        let photoData = Data(repeating: 0xFF, count: 1024) // 1KB
        let request = UpdateProfilePhotoRequest(
            userId: userId,
            photoData: photoData,
            fileExtension: "jpg",
            cropRect: nil
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == true)
        #expect(response.photoUrl != nil)
        #expect(response.thumbnailUrl != nil)
        #expect(response.photoUrl?.contains(userId) == true)
    }
    
    @Test("Update profile photo succeeds with valid PNG")
    func updateProfilePhotoSucceedsWithPng() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        let photoData = Data(repeating: 0x89, count: 2048)
        let request = UpdateProfilePhotoRequest(
            userId: userId,
            photoData: photoData,
            fileExtension: "png",
            cropRect: nil
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == true)
        #expect(response.photoUrl?.contains(".png") == true)
    }
    
    @Test("Update profile photo succeeds with JPEG uppercase extension")
    func updateProfilePhotoSucceedsWithUppercaseExtension() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        let photoData = Data(repeating: 0xFF, count: 1024)
        let request = UpdateProfilePhotoRequest(
            userId: userId,
            photoData: photoData,
            fileExtension: "JPEG",
            cropRect: nil
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == true)
    }
    
    // MARK: - Validation Tests
    
    @Test("Update profile photo fails with file too large")
    func updateProfilePhotoFailsWithFileTooLarge() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        // Create data larger than 10MB limit
        let largeData = Data(repeating: 0xFF, count: 11 * 1024 * 1024)
        let request = UpdateProfilePhotoRequest(
            userId: userId,
            photoData: largeData,
            fileExtension: "jpg",
            cropRect: nil
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == false)
        #expect(response.photoUrl == nil)
        #expect(response.message.contains("10MB"))
    }
    
    @Test("Update profile photo fails with invalid file type")
    func updateProfilePhotoFailsWithInvalidFileType() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        let photoData = Data(repeating: 0xFF, count: 1024)
        let request = UpdateProfilePhotoRequest(
            userId: userId,
            photoData: photoData,
            fileExtension: "gif",
            cropRect: nil
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == false)
        #expect(response.photoUrl == nil)
        #expect(response.message.contains("Invalid file type"))
    }
    
    @Test("Update profile photo fails with BMP file type")
    func updateProfilePhotoFailsWithBmpFileType() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        let photoData = Data(repeating: 0xFF, count: 1024)
        let request = UpdateProfilePhotoRequest(
            userId: userId,
            photoData: photoData,
            fileExtension: "bmp",
            cropRect: nil
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == false)
    }
    
    @Test("Update profile photo succeeds at exactly 10MB limit")
    func updateProfilePhotoSucceedsAtLimit() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        let exactlyMaxData = Data(repeating: 0xFF, count: 10 * 1024 * 1024)
        let request = UpdateProfilePhotoRequest(
            userId: userId,
            photoData: exactlyMaxData,
            fileExtension: "jpg",
            cropRect: nil
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == true)
    }
    
    // MARK: - Error Tests
    
    @Test("Update profile photo fails when user not found")
    func updateProfilePhotoFailsWhenUserNotFound() async throws {
        // Given - no user in repository
        let photoData = Data(repeating: 0xFF, count: 1024)
        let request = UpdateProfilePhotoRequest(
            userId: "non-existent",
            photoData: photoData,
            fileExtension: "jpg",
            cropRect: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
}
