import FirebaseCore
import Troop900Data
import Troop900Domain

#if canImport(UIKit)
import UIKit
#endif

/// Central place to construct shared dependencies (composition root helpers).
public enum AppEnvironment {
    
    /// Creates an in-memory data container for local development and testing.
    /// This provides all repositories and services using in-memory stubs,
    /// allowing development without Firebase.
    ///
    /// - Parameters:
    ///   - initialData: Optional initial data to seed the repositories
    /// - Returns: A configured InMemoryDataContainer with all dependencies wired up
    public static func makeInMemoryDataContainer(
        initialData: InMemoryInitialData? = nil
    ) -> InMemoryDataContainer {
        let initialUsers = initialData?.users ?? []
        let initialHouseholds = initialData?.households ?? []
        let initialShifts = initialData?.shifts ?? []
        let initialAssignments = initialData?.assignments ?? []
        let initialAttendanceRecords = initialData?.attendanceRecords ?? []
        let initialSeasons = initialData?.seasons ?? []
        let initialInviteCodes = initialData?.inviteCodes ?? []
        let initialMessages = initialData?.messages ?? []
        let initialFamilyUnits = initialData?.familyUnits ?? []
        let initialTemplates = initialData?.templates ?? []
        let initialUserId = initialData?.currentUserId
        
        return InMemoryDataContainer(
            initialUsers: initialUsers,
            initialHouseholds: initialHouseholds,
            initialShifts: initialShifts,
            initialAssignments: initialAssignments,
            initialAttendanceRecords: initialAttendanceRecords,
            initialSeasons: initialSeasons,
            initialInviteCodes: initialInviteCodes,
            initialMessages: initialMessages,
            initialFamilyUnits: initialFamilyUnits,
            initialTemplates: initialTemplates,
            initialUserId: initialUserId
        )
    }
    
    // In the future, we can expose factory methods to build Firebase-based
    // repositories and services here, e.g.:
    //
    // public static func makeFirebaseDataLayer() -> FirebaseDataContainer { ... }
}

/// Container for initial data when creating an in-memory data container.
public struct InMemoryInitialData {
    public let users: [User]
    public let households: [Household]
    public let shifts: [Shift]
    public let assignments: [Assignment]
    public let attendanceRecords: [AttendanceRecord]
    public let seasons: [Season]
    public let inviteCodes: [InviteCode]
    public let messages: [Message]
    public let familyUnits: [FamilyUnit]
    public let templates: [ShiftTemplate]
    public let currentUserId: UserId?
    
    public init(
        users: [User] = [],
        households: [Household] = [],
        shifts: [Shift] = [],
        assignments: [Assignment] = [],
        attendanceRecords: [AttendanceRecord] = [],
        seasons: [Season] = [],
        inviteCodes: [InviteCode] = [],
        messages: [Message] = [],
        familyUnits: [FamilyUnit] = [],
        templates: [ShiftTemplate] = [],
        currentUserId: UserId? = nil
    ) {
        self.users = users
        self.households = households
        self.shifts = shifts
        self.assignments = assignments
        self.attendanceRecords = attendanceRecords
        self.seasons = seasons
        self.inviteCodes = inviteCodes
        self.messages = messages
        self.familyUnits = familyUnits
        self.templates = templates
        self.currentUserId = currentUserId
    }
}

#if canImport(UIKit)
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
#endif


