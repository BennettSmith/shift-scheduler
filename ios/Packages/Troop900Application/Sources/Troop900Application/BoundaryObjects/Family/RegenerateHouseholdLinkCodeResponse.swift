import Foundation

/// Response after regenerating a household's link code.
/// Used for security when the existing code may be compromised.
public struct RegenerateHouseholdLinkCodeResponse: Sendable, Equatable {
    /// Whether the regeneration succeeded
    public let success: Bool
    
    /// The new household link code
    public let newLinkCode: String?
    
    /// Human-readable message describing the result
    public let message: String
    
    /// When the code was regenerated
    public let regeneratedAt: Date?
    
    public init(success: Bool, newLinkCode: String?, message: String, regeneratedAt: Date?) {
        self.success = success
        self.newLinkCode = newLinkCode
        self.message = message
        self.regeneratedAt = regeneratedAt
    }
}
