import Foundation
import Testing
@testable import Troop900Domain

@Suite("DomainError Tests")
struct DomainErrorTests {
    
    // MARK: - Debug Messages
    
    @Test("Debug message for shift full")
    func shiftFullDebugMessage() {
        let error = DomainError.shiftFull
        #expect(error.debugMessage == "DomainError.shiftFull")
    }
    
    @Test("Debug message for invalid input")
    func invalidInputDebugMessage() {
        let error = DomainError.invalidInput("Test message")
        #expect(error.debugMessage == "DomainError.invalidInput: Test message")
    }
    
    @Test("Debug message for operation failed")
    func operationFailedDebugMessage() {
        let error = DomainError.operationFailed("Test failure")
        #expect(error.debugMessage == "DomainError.operationFailed: Test failure")
    }
    
    @Test("Debug message for unknown error")
    func unknownErrorDebugMessage() {
        struct TestError: Error {
            var localizedDescription: String { "Test error description" }
        }
        let error = DomainError.unknown(TestError())
        #expect(error.debugMessage.hasPrefix("DomainError.unknown:"))
    }
    
    // MARK: - CustomStringConvertible Conformance
    
    @Test("Description matches debug message")
    func descriptionMatchesDebugMessage() {
        let error = DomainError.shiftNotFound
        #expect(error.description == error.debugMessage)
    }
    
    // MARK: - Sendable Conformance
    
    @Test("Error is Sendable")
    func errorIsSendable() {
        // This test verifies that DomainError is Sendable at compile time
        let error: any Error & Sendable = DomainError.notAuthenticated
        #expect(error is DomainError)
    }
}
