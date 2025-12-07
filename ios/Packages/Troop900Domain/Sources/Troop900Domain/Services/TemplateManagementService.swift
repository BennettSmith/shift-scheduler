import Foundation

/// Protocol for shift template management remote operations (Cloud Functions).
public protocol TemplateManagementService: Sendable {
    /// Create a new shift template.
    /// - Parameter request: The create template request.
    /// - Returns: The created template's ID.
    func createTemplate(request: CreateTemplateRequest) async throws -> String
    
    /// Update an existing shift template.
    /// - Parameter request: The update template request.
    func updateTemplate(request: UpdateTemplateRequest) async throws
    
    /// Deactivate a shift template.
    /// - Parameter templateId: The template's ID.
    func deactivateTemplate(templateId: String) async throws
    
    /// Generate shifts from a template.
    /// - Parameter request: The generate shifts request.
    /// - Returns: The IDs of the created shifts.
    func generateShiftsFromTemplate(request: GenerateShiftsRequest) async throws -> [String]
}

/// Request to create a new shift template.
public struct CreateTemplateRequest: Sendable, Codable {
    public let name: String
    public let startTime: Date
    public let endTime: Date
    public let requiredScouts: Int
    public let requiredParents: Int
    public let location: String
    public let label: String?
    public let notes: String?
    
    public init(
        name: String,
        startTime: Date,
        endTime: Date,
        requiredScouts: Int,
        requiredParents: Int,
        location: String,
        label: String?,
        notes: String?
    ) {
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.requiredScouts = requiredScouts
        self.requiredParents = requiredParents
        self.location = location
        self.label = label
        self.notes = notes
    }
}

/// Request to update an existing shift template.
public struct UpdateTemplateRequest: Sendable, Codable {
    public let templateId: String
    public let name: String?
    public let startTime: Date?
    public let endTime: Date?
    public let requiredScouts: Int?
    public let requiredParents: Int?
    public let location: String?
    public let label: String?
    public let notes: String?
    
    public init(
        templateId: String,
        name: String? = nil,
        startTime: Date? = nil,
        endTime: Date? = nil,
        requiredScouts: Int? = nil,
        requiredParents: Int? = nil,
        location: String? = nil,
        label: String? = nil,
        notes: String? = nil
    ) {
        self.templateId = templateId
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.requiredScouts = requiredScouts
        self.requiredParents = requiredParents
        self.location = location
        self.label = label
        self.notes = notes
    }
}

/// Request to generate shifts from a template.
public struct GenerateShiftsRequest: Sendable, Codable {
    public let templateId: String
    public let dates: [Date]
    public let seasonId: String?
    
    public init(templateId: String, dates: [Date], seasonId: String?) {
        self.templateId = templateId
        self.dates = dates
        self.seasonId = seasonId
    }
}
