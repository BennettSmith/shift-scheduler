import Foundation
import Troop900Domain

/// Mock implementation of SeasonManagementService for testing
public final class MockSeasonManagementService: SeasonManagementService, @unchecked Sendable {
    
    // MARK: - Configurable Results
    
    public var createSeasonResult: Result<String, Error>?
    public var publishSeasonError: Error?
    public var completeSeasonError: Error?
    public var archiveSeasonError: Error?
    
    // MARK: - Call Tracking
    
    public var createSeasonCallCount = 0
    public var createSeasonCalledWith: [CreateSeasonRequest] = []
    
    public var publishSeasonCallCount = 0
    public var publishSeasonCalledWith: [String] = []
    
    public var completeSeasonCallCount = 0
    public var completeSeasonCalledWith: [String] = []
    
    public var archiveSeasonCallCount = 0
    public var archiveSeasonCalledWith: [String] = []
    
    // MARK: - SeasonManagementService Implementation
    
    public func createSeason(request: CreateSeasonRequest) async throws -> String {
        createSeasonCallCount += 1
        createSeasonCalledWith.append(request)
        
        if let result = createSeasonResult {
            return try result.get()
        }
        
        // Return a generated season ID
        return "season-\(UUID().uuidString.prefix(8))"
    }
    
    public func publishSeason(seasonId: String) async throws {
        publishSeasonCallCount += 1
        publishSeasonCalledWith.append(seasonId)
        
        if let error = publishSeasonError {
            throw error
        }
    }
    
    public func completeSeason(seasonId: String) async throws {
        completeSeasonCallCount += 1
        completeSeasonCalledWith.append(seasonId)
        
        if let error = completeSeasonError {
            throw error
        }
    }
    
    public func archiveSeason(seasonId: String) async throws {
        archiveSeasonCallCount += 1
        archiveSeasonCalledWith.append(seasonId)
        
        if let error = archiveSeasonError {
            throw error
        }
    }
    
    // MARK: - Test Helpers
    
    /// Resets all state and call tracking
    public func reset() {
        createSeasonResult = nil
        publishSeasonError = nil
        completeSeasonError = nil
        archiveSeasonError = nil
        createSeasonCallCount = 0
        createSeasonCalledWith.removeAll()
        publishSeasonCallCount = 0
        publishSeasonCalledWith.removeAll()
        completeSeasonCallCount = 0
        completeSeasonCalledWith.removeAll()
        archiveSeasonCallCount = 0
        archiveSeasonCalledWith.removeAll()
    }
}
