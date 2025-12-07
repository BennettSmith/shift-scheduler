import Foundation
import Troop900Domain

/// Mock implementation of ScheduleGenerationService for testing
public final class MockScheduleGenerationService: ScheduleGenerationService, @unchecked Sendable {
    
    // MARK: - Configurable Results
    
    public var generateScheduleResult: Result<ScheduleGenerationResult, Error>?
    public var publishScheduleError: Error?
    
    /// Pre-configured shift IDs to return from generate
    public var generatedShiftIds: [String] = []
    
    // MARK: - Call Tracking
    
    public var generateScheduleCallCount = 0
    public var generateScheduleCalledWith: [ScheduleGenerationRequest] = []
    
    public var publishScheduleCallCount = 0
    public var publishScheduleCalledWith: [(seasonId: String, shiftIds: [String])] = []
    
    // MARK: - ScheduleGenerationService Implementation
    
    public func generateSchedule(request: ScheduleGenerationRequest) async throws -> ScheduleGenerationResult {
        generateScheduleCallCount += 1
        generateScheduleCalledWith.append(request)
        
        if let result = generateScheduleResult {
            return try result.get()
        }
        
        // Use pre-configured shift IDs or generate some
        let shiftIds = generatedShiftIds.isEmpty 
            ? (0..<10).map { "shift-\($0)" }
            : generatedShiftIds
        
        return ScheduleGenerationResult(
            success: true,
            shiftIds: shiftIds,
            message: "Generated \(shiftIds.count) shifts"
        )
    }
    
    public func publishSchedule(seasonId: String, shiftIds: [String]) async throws {
        publishScheduleCallCount += 1
        publishScheduleCalledWith.append((seasonId, shiftIds))
        
        if let error = publishScheduleError {
            throw error
        }
    }
    
    // MARK: - Test Helpers
    
    /// Resets all state and call tracking
    public func reset() {
        generateScheduleResult = nil
        publishScheduleError = nil
        generatedShiftIds.removeAll()
        generateScheduleCallCount = 0
        generateScheduleCalledWith.removeAll()
        publishScheduleCallCount = 0
        publishScheduleCalledWith.removeAll()
    }
}
