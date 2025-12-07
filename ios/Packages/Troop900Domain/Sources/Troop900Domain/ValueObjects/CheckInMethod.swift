import Foundation

/// Represents the method used for checking in to a shift.
public enum CheckInMethod: String, Sendable, Codable {
    case qrCode = "qr_code"
    case manual
    case adminOverride = "admin_override"
    
    public var displayName: String {
        switch self {
        case .qrCode: return "QR Code"
        case .manual: return "Manual"
        case .adminOverride: return "Admin Override"
        }
    }
}
