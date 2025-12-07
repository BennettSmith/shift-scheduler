import Foundation
import Troop900Domain

/// Mock implementation of TemplateManagementService for testing
public final class MockTemplateManagementService: TemplateManagementService, @unchecked Sendable {
    
    // MARK: - Configurable Results
    
    public var createTemplateResult: Result<String, Error>?
    public var updateTemplateError: Error?
    public var deactivateTemplateError: Error?
    public var generateShiftsFromTemplateResult: Result<[String], Error>?
    
    /// Pre-configured shift IDs to return from generateShiftsFromTemplate
    public var generatedShiftIds: [String] = []
    
    // MARK: - Call Tracking
    
    public var createTemplateCallCount = 0
    public var createTemplateCalledWith: [CreateTemplateRequest] = []
    
    public var updateTemplateCallCount = 0
    public var updateTemplateCalledWith: [UpdateTemplateRequest] = []
    
    public var deactivateTemplateCallCount = 0
    public var deactivateTemplateCalledWith: [String] = []
    
    public var generateShiftsFromTemplateCallCount = 0
    public var generateShiftsFromTemplateCalledWith: [GenerateShiftsRequest] = []
    
    // MARK: - TemplateManagementService Implementation
    
    public func createTemplate(request: CreateTemplateRequest) async throws -> String {
        createTemplateCallCount += 1
        createTemplateCalledWith.append(request)
        
        if let result = createTemplateResult {
            return try result.get()
        }
        
        // Return a generated template ID
        return "template-\(UUID().uuidString.prefix(8))"
    }
    
    public func updateTemplate(request: UpdateTemplateRequest) async throws {
        updateTemplateCallCount += 1
        updateTemplateCalledWith.append(request)
        
        if let error = updateTemplateError {
            throw error
        }
    }
    
    public func deactivateTemplate(templateId: String) async throws {
        deactivateTemplateCallCount += 1
        deactivateTemplateCalledWith.append(templateId)
        
        if let error = deactivateTemplateError {
            throw error
        }
    }
    
    public func generateShiftsFromTemplate(request: GenerateShiftsRequest) async throws -> [String] {
        generateShiftsFromTemplateCallCount += 1
        generateShiftsFromTemplateCalledWith.append(request)
        
        if let result = generateShiftsFromTemplateResult {
            return try result.get()
        }
        
        // Use pre-configured shift IDs or generate based on dates
        if !generatedShiftIds.isEmpty {
            return generatedShiftIds
        }
        
        return request.dates.map { _ in "shift-\(UUID().uuidString.prefix(8))" }
    }
    
    // MARK: - Test Helpers
    
    /// Resets all state and call tracking
    public func reset() {
        createTemplateResult = nil
        updateTemplateError = nil
        deactivateTemplateError = nil
        generateShiftsFromTemplateResult = nil
        generatedShiftIds.removeAll()
        createTemplateCallCount = 0
        createTemplateCalledWith.removeAll()
        updateTemplateCallCount = 0
        updateTemplateCalledWith.removeAll()
        deactivateTemplateCallCount = 0
        deactivateTemplateCalledWith.removeAll()
        generateShiftsFromTemplateCallCount = 0
        generateShiftsFromTemplateCalledWith.removeAll()
    }
}
