import Foundation

/// Domain-level errors that represent business rule violations or expected failure scenarios.
public enum DomainError: Error, Sendable {
    // MARK: - Authentication Errors
    case notAuthenticated
    case unauthorized
    case invalidCredentials
    
    // MARK: - User Errors
    case userNotFound
    case userAlreadyExists
    case userNotClaimed
    case userAccountInactive
    case invalidClaimCode
    
    // MARK: - Household Errors
    case householdNotFound
    case householdLinkCodeInvalid
    case userNotInHousehold
    case cannotManageHousehold
    
    // MARK: - Shift Errors
    case shiftNotFound
    case shiftFull
    case shiftNotPublished
    case shiftCancelled
    case shiftInPast
    case shiftAlreadyStarted
    case invalidShiftTime
    
    // MARK: - Assignment Errors
    case assignmentNotFound
    case alreadyAssignedToShift
    case assignmentAlreadyCancelled
    case cannotCancelAssignment
    case assignmentNotActive
    
    // MARK: - Attendance Errors
    case attendanceRecordNotFound
    case alreadyCheckedIn
    case alreadyCheckedOut
    case notCheckedIn
    case invalidCheckInTime
    case invalidQRCode
    
    // MARK: - Invite Code Errors
    case inviteCodeNotFound
    case inviteCodeExpired
    case inviteCodeAlreadyUsed
    case inviteCodeInvalid
    
    // MARK: - Season Errors
    case seasonNotFound
    case noActiveSeason
    case seasonAlreadyActive
    case invalidSeasonDates
    
    // MARK: - Template Errors
    case templateNotFound
    case templateInactive
    
    // MARK: - Message Errors
    case messageNotFound
    case invalidMessageRecipients
    
    // MARK: - General Errors
    case invalidInput(String)
    case operationFailed(String)
    case networkError
    case unknown(Error)
    
    // MARK: - User-Facing Messages
    
    /// Provides a user-friendly error message for display in the UI.
    public var userMessage: String {
        switch self {
        // Authentication
        case .notAuthenticated:
            return "You must be signed in to perform this action."
        case .unauthorized:
            return "You don't have permission to perform this action."
        case .invalidCredentials:
            return "Invalid credentials. Please try again."
            
        // User
        case .userNotFound:
            return "User not found."
        case .userAlreadyExists:
            return "A user with this email already exists."
        case .userNotClaimed:
            return "You must claim your profile before signing up for shifts."
        case .userAccountInactive:
            return "Your account is inactive. Please contact an administrator."
        case .invalidClaimCode:
            return "Invalid claim code. Please check and try again."
            
        // Household
        case .householdNotFound:
            return "Household not found."
        case .householdLinkCodeInvalid:
            return "Invalid household link code."
        case .userNotInHousehold:
            return "You are not a member of this household."
        case .cannotManageHousehold:
            return "You don't have permission to manage this household."
            
        // Shift
        case .shiftNotFound:
            return "Shift not found."
        case .shiftFull:
            return "This shift is already full."
        case .shiftNotPublished:
            return "This shift is not available for signup yet."
        case .shiftCancelled:
            return "This shift has been cancelled."
        case .shiftInPast:
            return "This shift is in the past."
        case .shiftAlreadyStarted:
            return "This shift has already started."
        case .invalidShiftTime:
            return "Invalid shift time. End time must be after start time."
            
        // Assignment
        case .assignmentNotFound:
            return "Assignment not found."
        case .alreadyAssignedToShift:
            return "You are already signed up for this shift."
        case .assignmentAlreadyCancelled:
            return "This assignment has already been cancelled."
        case .cannotCancelAssignment:
            return "This assignment cannot be cancelled at this time."
        case .assignmentNotActive:
            return "This assignment is not active."
            
        // Attendance
        case .attendanceRecordNotFound:
            return "Attendance record not found."
        case .alreadyCheckedIn:
            return "You are already checked in."
        case .alreadyCheckedOut:
            return "You have already checked out."
        case .notCheckedIn:
            return "You must check in before checking out."
        case .invalidCheckInTime:
            return "Invalid check-in time."
        case .invalidQRCode:
            return "Invalid QR code. Please try again."
            
        // Invite Code
        case .inviteCodeNotFound:
            return "Invite code not found."
        case .inviteCodeExpired:
            return "This invite code has expired."
        case .inviteCodeAlreadyUsed:
            return "This invite code has already been used."
        case .inviteCodeInvalid:
            return "Invalid invite code."
            
        // Season
        case .seasonNotFound:
            return "Season not found."
        case .noActiveSeason:
            return "There is no active season."
        case .seasonAlreadyActive:
            return "A season is already active."
        case .invalidSeasonDates:
            return "Invalid season dates. End date must be after start date."
            
        // Template
        case .templateNotFound:
            return "Template not found."
        case .templateInactive:
            return "This template is inactive."
            
        // Message
        case .messageNotFound:
            return "Message not found."
        case .invalidMessageRecipients:
            return "Invalid message recipients."
            
        // General
        case .invalidInput(let message):
            return message
        case .operationFailed(let message):
            return message
        case .networkError:
            return "Network error. Please check your connection and try again."
        case .unknown:
            return "An unexpected error occurred. Please try again."
        }
    }
    
    // MARK: - Developer-Facing Messages
    
    /// Provides a detailed error message for logging and debugging.
    public var debugMessage: String {
        switch self {
        case .unknown(let error):
            return "DomainError.unknown: \(error.localizedDescription)"
        case .invalidInput(let message):
            return "DomainError.invalidInput: \(message)"
        case .operationFailed(let message):
            return "DomainError.operationFailed: \(message)"
        case .notAuthenticated:
            return "DomainError.notAuthenticated"
        case .unauthorized:
            return "DomainError.unauthorized"
        case .invalidCredentials:
            return "DomainError.invalidCredentials"
        case .userNotFound:
            return "DomainError.userNotFound"
        case .userAlreadyExists:
            return "DomainError.userAlreadyExists"
        case .userNotClaimed:
            return "DomainError.userNotClaimed"
        case .userAccountInactive:
            return "DomainError.userAccountInactive"
        case .invalidClaimCode:
            return "DomainError.invalidClaimCode"
        case .householdNotFound:
            return "DomainError.householdNotFound"
        case .householdLinkCodeInvalid:
            return "DomainError.householdLinkCodeInvalid"
        case .userNotInHousehold:
            return "DomainError.userNotInHousehold"
        case .cannotManageHousehold:
            return "DomainError.cannotManageHousehold"
        case .shiftNotFound:
            return "DomainError.shiftNotFound"
        case .shiftFull:
            return "DomainError.shiftFull"
        case .shiftNotPublished:
            return "DomainError.shiftNotPublished"
        case .shiftCancelled:
            return "DomainError.shiftCancelled"
        case .shiftInPast:
            return "DomainError.shiftInPast"
        case .shiftAlreadyStarted:
            return "DomainError.shiftAlreadyStarted"
        case .invalidShiftTime:
            return "DomainError.invalidShiftTime"
        case .assignmentNotFound:
            return "DomainError.assignmentNotFound"
        case .alreadyAssignedToShift:
            return "DomainError.alreadyAssignedToShift"
        case .assignmentAlreadyCancelled:
            return "DomainError.assignmentAlreadyCancelled"
        case .cannotCancelAssignment:
            return "DomainError.cannotCancelAssignment"
        case .assignmentNotActive:
            return "DomainError.assignmentNotActive"
        case .attendanceRecordNotFound:
            return "DomainError.attendanceRecordNotFound"
        case .alreadyCheckedIn:
            return "DomainError.alreadyCheckedIn"
        case .alreadyCheckedOut:
            return "DomainError.alreadyCheckedOut"
        case .notCheckedIn:
            return "DomainError.notCheckedIn"
        case .invalidCheckInTime:
            return "DomainError.invalidCheckInTime"
        case .invalidQRCode:
            return "DomainError.invalidQRCode"
        case .inviteCodeNotFound:
            return "DomainError.inviteCodeNotFound"
        case .inviteCodeExpired:
            return "DomainError.inviteCodeExpired"
        case .inviteCodeAlreadyUsed:
            return "DomainError.inviteCodeAlreadyUsed"
        case .inviteCodeInvalid:
            return "DomainError.inviteCodeInvalid"
        case .seasonNotFound:
            return "DomainError.seasonNotFound"
        case .noActiveSeason:
            return "DomainError.noActiveSeason"
        case .seasonAlreadyActive:
            return "DomainError.seasonAlreadyActive"
        case .invalidSeasonDates:
            return "DomainError.invalidSeasonDates"
        case .templateNotFound:
            return "DomainError.templateNotFound"
        case .templateInactive:
            return "DomainError.templateInactive"
        case .messageNotFound:
            return "DomainError.messageNotFound"
        case .invalidMessageRecipients:
            return "DomainError.invalidMessageRecipients"
        case .networkError:
            return "DomainError.networkError"
        }
    }
}

// MARK: - LocalizedError Conformance

extension DomainError: LocalizedError {
    public var errorDescription: String? {
        userMessage
    }
}

// MARK: - CustomStringConvertible Conformance

extension DomainError: CustomStringConvertible {
    public var description: String {
        debugMessage
    }
}
