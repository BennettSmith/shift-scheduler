import Foundation
import Troop900Domain

/// Response after updating profile photo.
public struct UpdateProfilePhotoResponse: Sendable, Equatable {
    /// Whether the update succeeded
    public let success: Bool
    
    /// URL of the uploaded photo
    public let photoUrl: String?
    
    /// URL of the thumbnail version
    public let thumbnailUrl: String?
    
    /// Human-readable message
    public let message: String
    
    public init(
        success: Bool,
        photoUrl: String?,
        thumbnailUrl: String?,
        message: String
    ) {
        self.success = success
        self.photoUrl = photoUrl
        self.thumbnailUrl = thumbnailUrl
        self.message = message
    }
}
