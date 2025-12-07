import Foundation

/// Represents a geographic location.
public struct GeoLocation: Equatable, Sendable, Codable {
    public let latitude: Double
    public let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
