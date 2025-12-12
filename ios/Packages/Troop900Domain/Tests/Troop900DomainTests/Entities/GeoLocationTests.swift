import Foundation
import Testing
@testable import Troop900Domain

@Suite("GeoLocation Tests")
struct GeoLocationTests {
    
    @Test("GeoLocation initialization")
    func geoLocationInitialization() {
        let location = GeoLocation(latitude: 37.7749, longitude: -122.4194)
        
        #expect(location.latitude == 37.7749)
        #expect(location.longitude == -122.4194)
    }
    
    @Test("GeoLocation equality")
    func geoLocationEquality() {
        let location1 = GeoLocation(latitude: 37.7749, longitude: -122.4194)
        let location2 = GeoLocation(latitude: 37.7749, longitude: -122.4194)
        
        #expect(location1 == location2)
    }
    
    @Test("GeoLocation inequality")
    func geoLocationInequality() {
        let location1 = GeoLocation(latitude: 37.7749, longitude: -122.4194)
        let location2 = GeoLocation(latitude: 40.7128, longitude: -74.0060)
        
        #expect(location1 != location2)
    }
    
    @Test("GeoLocation is Codable")
    func geoLocationCodable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let location = GeoLocation(latitude: 37.7749, longitude: -122.4194)
        let data = try encoder.encode(location)
        let decoded = try decoder.decode(GeoLocation.self, from: data)
        
        #expect(decoded == location)
    }
}
