import Foundation
import Troop900Domain

/// Response after checking out from a shift.
public struct CheckOutResponse: Sendable, Equatable {
    public let success: Bool
    public let checkOutTime: Date
    public let hoursWorked: Double
    public let message: String
    
    public init(success: Bool, checkOutTime: Date, hoursWorked: Double, message: String) {
        self.success = success
        self.checkOutTime = checkOutTime
        self.hoursWorked = hoursWorked
        self.message = message
    }
}
