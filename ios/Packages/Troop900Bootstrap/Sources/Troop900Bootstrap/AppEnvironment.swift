import UIKit
import FirebaseCore
import Troop900Data

/// Central place to construct shared dependencies (composition root helpers).
public enum AppEnvironment {

    // In the future, we can expose factory methods to build repositories,
    // services, and view-model dependency containers here, e.g.:
    //
    // public static func makeDataLayer() -> DataLayer { ... }
}

/// A UIKit app delegate that configures Firebase at launch.
/// Lives in Troop900Bootstrap so the app target does not need to import Firebase.
public final class BootstrapAppDelegate: NSObject, UIApplicationDelegate {

    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}


