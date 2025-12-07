import Foundation
import Troop900Domain
import Troop900Application

/// Placeholder view-model type for the Troop900Presentation package.
/// Replace with real SwiftUI view models that depend on domain use cases.
public final class PlaceholderViewModel: ObservableObject {
    @Published public var title: String

    public init(title: String = "Shift Scheduler") {
        self.title = title
    }
}


