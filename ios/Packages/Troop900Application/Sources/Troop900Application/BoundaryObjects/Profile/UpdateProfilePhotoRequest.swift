import Foundation

/// Request to update a user's profile photo.
public struct UpdateProfilePhotoRequest: Sendable, Equatable {
    /// The ID of the user updating their photo
    public let userId: String
    
    /// The photo data (JPEG or PNG)
    public let photoData: Data
    
    /// The file extension (e.g., "jpg", "png")
    public let fileExtension: String
    
    /// Optional crop/resize parameters
    public let cropRect: CropRect?
    
    public init(
        userId: String,
        photoData: Data,
        fileExtension: String,
        cropRect: CropRect?
    ) {
        self.userId = userId
        self.photoData = photoData
        self.fileExtension = fileExtension
        self.cropRect = cropRect
    }
}

/// Rectangle for cropping photo.
public struct CropRect: Sendable, Equatable, Codable {
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double
    
    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}
