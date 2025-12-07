import Testing
import Foundation
@testable import Troop900Domain

@Suite("DomainError Tests")
struct DomainErrorTests {
    
    // MARK: - Authentication Errors
    
    @Test("Not authenticated error has correct user message")
    func notAuthenticatedMessage() {
        let error = DomainError.notAuthenticated
        #expect(error.userMessage == "You must be signed in to perform this action.")
    }
    
    @Test("Unauthorized error has correct user message")
    func unauthorizedMessage() {
        let error = DomainError.unauthorized
        #expect(error.userMessage == "You don't have permission to perform this action.")
    }
    
    @Test("Invalid credentials error has correct user message")
    func invalidCredentialsMessage() {
        let error = DomainError.invalidCredentials
        #expect(error.userMessage == "Invalid credentials. Please try again.")
    }
    
    // MARK: - User Errors
    
    @Test("User not found error has correct user message")
    func userNotFoundMessage() {
        let error = DomainError.userNotFound
        #expect(error.userMessage == "User not found.")
    }
    
    @Test("User already exists error has correct user message")
    func userAlreadyExistsMessage() {
        let error = DomainError.userAlreadyExists
        #expect(error.userMessage == "A user with this email already exists.")
    }
    
    @Test("User not claimed error has correct user message")
    func userNotClaimedMessage() {
        let error = DomainError.userNotClaimed
        #expect(error.userMessage == "You must claim your profile before signing up for shifts.")
    }
    
    @Test("User account inactive error has correct user message")
    func userAccountInactiveMessage() {
        let error = DomainError.userAccountInactive
        #expect(error.userMessage == "Your account is inactive. Please contact an administrator.")
    }
    
    // MARK: - Shift Errors
    
    @Test("Shift not found error has correct user message")
    func shiftNotFoundMessage() {
        let error = DomainError.shiftNotFound
        #expect(error.userMessage == "Shift not found.")
    }
    
    @Test("Shift full error has correct user message")
    func shiftFullMessage() {
        let error = DomainError.shiftFull
        #expect(error.userMessage == "This shift is already full.")
    }
    
    @Test("Shift not published error has correct user message")
    func shiftNotPublishedMessage() {
        let error = DomainError.shiftNotPublished
        #expect(error.userMessage == "This shift is not available for signup yet.")
    }
    
    @Test("Shift cancelled error has correct user message")
    func shiftCancelledMessage() {
        let error = DomainError.shiftCancelled
        #expect(error.userMessage == "This shift has been cancelled.")
    }
    
    @Test("Shift in past error has correct user message")
    func shiftInPastMessage() {
        let error = DomainError.shiftInPast
        #expect(error.userMessage == "This shift is in the past.")
    }
    
    @Test("Invalid shift time error has correct user message")
    func invalidShiftTimeMessage() {
        let error = DomainError.invalidShiftTime
        #expect(error.userMessage == "Invalid shift time. End time must be after start time.")
    }
    
    // MARK: - Assignment Errors
    
    @Test("Assignment not found error has correct user message")
    func assignmentNotFoundMessage() {
        let error = DomainError.assignmentNotFound
        #expect(error.userMessage == "Assignment not found.")
    }
    
    @Test("Already assigned to shift error has correct user message")
    func alreadyAssignedToShiftMessage() {
        let error = DomainError.alreadyAssignedToShift
        #expect(error.userMessage == "You are already signed up for this shift.")
    }
    
    @Test("Cannot cancel assignment error has correct user message")
    func cannotCancelAssignmentMessage() {
        let error = DomainError.cannotCancelAssignment
        #expect(error.userMessage == "This assignment cannot be cancelled at this time.")
    }
    
    // MARK: - Attendance Errors
    
    @Test("Already checked in error has correct user message")
    func alreadyCheckedInMessage() {
        let error = DomainError.alreadyCheckedIn
        #expect(error.userMessage == "You are already checked in.")
    }
    
    @Test("Already checked out error has correct user message")
    func alreadyCheckedOutMessage() {
        let error = DomainError.alreadyCheckedOut
        #expect(error.userMessage == "You have already checked out.")
    }
    
    @Test("Not checked in error has correct user message")
    func notCheckedInMessage() {
        let error = DomainError.notCheckedIn
        #expect(error.userMessage == "You must check in before checking out.")
    }
    
    @Test("Invalid QR code error has correct user message")
    func invalidQRCodeMessage() {
        let error = DomainError.invalidQRCode
        #expect(error.userMessage == "Invalid QR code. Please try again.")
    }
    
    // MARK: - Invite Code Errors
    
    @Test("Invite code not found error has correct user message")
    func inviteCodeNotFoundMessage() {
        let error = DomainError.inviteCodeNotFound
        #expect(error.userMessage == "Invite code not found.")
    }
    
    @Test("Invite code expired error has correct user message")
    func inviteCodeExpiredMessage() {
        let error = DomainError.inviteCodeExpired
        #expect(error.userMessage == "This invite code has expired.")
    }
    
    @Test("Invite code already used error has correct user message")
    func inviteCodeAlreadyUsedMessage() {
        let error = DomainError.inviteCodeAlreadyUsed
        #expect(error.userMessage == "This invite code has already been used.")
    }
    
    // MARK: - Season Errors
    
    @Test("Season not found error has correct user message")
    func seasonNotFoundMessage() {
        let error = DomainError.seasonNotFound
        #expect(error.userMessage == "Season not found.")
    }
    
    @Test("No active season error has correct user message")
    func noActiveSeasonMessage() {
        let error = DomainError.noActiveSeason
        #expect(error.userMessage == "There is no active season.")
    }
    
    @Test("Invalid season dates error has correct user message")
    func invalidSeasonDatesMessage() {
        let error = DomainError.invalidSeasonDates
        #expect(error.userMessage == "Invalid season dates. End date must be after start date.")
    }
    
    // MARK: - General Errors
    
    @Test("Invalid input error has custom message")
    func invalidInputCustomMessage() {
        let error = DomainError.invalidInput("Email is required")
        #expect(error.userMessage == "Email is required")
    }
    
    @Test("Operation failed error has custom message")
    func operationFailedCustomMessage() {
        let error = DomainError.operationFailed("Could not connect to server")
        #expect(error.userMessage == "Could not connect to server")
    }
    
    @Test("Network error has correct user message")
    func networkErrorMessage() {
        let error = DomainError.networkError
        #expect(error.userMessage == "Network error. Please check your connection and try again.")
    }
    
    @Test("Unknown error has generic message")
    func unknownErrorMessage() {
        struct TestError: Error {}
        let error = DomainError.unknown(TestError())
        #expect(error.userMessage == "An unexpected error occurred. Please try again.")
    }
    
    // MARK: - Debug Messages
    
    @Test("Debug message for shift full")
    func shiftFullDebugMessage() {
        let error = DomainError.shiftFull
        #expect(error.debugMessage == "shiftFull")
    }
    
    @Test("Debug message for invalid input")
    func invalidInputDebugMessage() {
        let error = DomainError.invalidInput("Test message")
        #expect(error.debugMessage == "Invalid input: Test message")
    }
    
    @Test("Debug message for operation failed")
    func operationFailedDebugMessage() {
        let error = DomainError.operationFailed("Test failure")
        #expect(error.debugMessage == "Operation failed: Test failure")
    }
    
    @Test("Debug message for unknown error")
    func unknownErrorDebugMessage() {
        struct TestError: Error {
            var localizedDescription: String { "Test error description" }
        }
        let error = DomainError.unknown(TestError())
        #expect(error.debugMessage.contains("Unknown error"))
    }
    
    // MARK: - LocalizedError Conformance
    
    @Test("Error description matches user message")
    func errorDescriptionMatchesUserMessage() {
        let error = DomainError.shiftFull
        #expect(error.errorDescription == error.userMessage)
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
