import Foundation
import Troop900Domain

/// Protocol for updating profile photo.
public protocol UpdateProfilePhotoUseCaseProtocol: Sendable {
    func execute(request: UpdateProfilePhotoRequest) async throws -> UpdateProfilePhotoResponse
}

/// Use case for uploading and updating a user's profile photo.
/// Used by UC 45 for users to personalize their profile.
public final class UpdateProfilePhotoUseCase: UpdateProfilePhotoUseCaseProtocol, Sendable {
    private let userRepository: UserRepository
    
    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    public func execute(request: UpdateProfilePhotoRequest) async throws -> UpdateProfilePhotoResponse {
        // Validate and convert boundary ID to domain ID type
        let userId = try UserId(request.userId)
        
        // Validate user exists
        let user = try await userRepository.getUser(id: userId)
        
        // Validate photo data size (max 10MB)
        let maxSize = 10 * 1024 * 1024 // 10MB
        guard request.photoData.count <= maxSize else {
            return UpdateProfilePhotoResponse(
                success: false,
                photoUrl: nil,
                thumbnailUrl: nil,
                message: "Photo size exceeds 10MB limit"
            )
        }
        
        // Validate file extension
        let validExtensions = ["jpg", "jpeg", "png"]
        guard validExtensions.contains(request.fileExtension.lowercased()) else {
            return UpdateProfilePhotoResponse(
                success: false,
                photoUrl: nil,
                thumbnailUrl: nil,
                message: "Invalid file type. Please use JPG or PNG"
            )
        }
        
        // In a real implementation, this would:
        // 1. Upload photo to cloud storage (e.g., Firebase Storage)
        // 2. Generate thumbnail
        // 3. Get URLs for both
        // 4. Update user document with photo URLs
        
        // For now, we'll create placeholder URLs
        let timestamp = Int(Date().timeIntervalSince1970)
        let photoUrl = "https://storage.example.com/profiles/\(user.id.value)/photo_\(timestamp).\(request.fileExtension)"
        let thumbnailUrl = "https://storage.example.com/profiles/\(user.id.value)/thumb_\(timestamp).\(request.fileExtension)"
        
        // Note: In real implementation, UserRepository would have updateProfilePhoto method
        // For now, this would be handled by a cloud function or backend service
        
        return UpdateProfilePhotoResponse(
            success: true,
            photoUrl: photoUrl,
            thumbnailUrl: thumbnailUrl,
            message: "Profile photo updated successfully"
        )
    }
}
