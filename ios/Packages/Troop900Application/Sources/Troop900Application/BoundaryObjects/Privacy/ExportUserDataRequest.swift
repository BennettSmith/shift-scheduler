import Foundation

/// Request to export all user data (GDPR/CCPA compliance).
public struct ExportUserDataRequest: Sendable, Equatable {
    /// The ID of the user requesting data export
    public let userId: String
    
    /// The ID of the user making the request (can be self or admin)
    public let requestingUserId: String
    
    /// Format for export (json, csv, etc.)
    public let format: ExportFormat
    
    /// Whether to include soft-deleted data
    public let includeSoftDeleted: Bool
    
    public init(
        userId: String,
        requestingUserId: String,
        format: ExportFormat,
        includeSoftDeleted: Bool
    ) {
        self.userId = userId
        self.requestingUserId = requestingUserId
        self.format = format
        self.includeSoftDeleted = includeSoftDeleted
    }
}

/// Export format options.
public enum ExportFormat: String, Sendable, Codable {
    case json
    case csv
}
