import Foundation
import Troop900Domain

/// Container that provides in-memory implementations of all repositories and services.
/// Use this for testing and local development without Firebase.
public final class InMemoryDataContainer {
    // MARK: - Repositories
    
    public let authRepository: AuthRepository
    public let userRepository: UserRepository
    public let householdRepository: HouseholdRepository
    public let shiftRepository: ShiftRepository
    public let assignmentRepository: AssignmentRepository
    public let attendanceRepository: AttendanceRepository
    public let seasonRepository: SeasonRepository
    public let inviteCodeRepository: InviteCodeRepository
    public let messageRepository: MessageRepository
    public let familyUnitRepository: FamilyUnitRepository
    public let templateRepository: TemplateRepository
    
    // MARK: - Services
    
    public let attendanceService: AttendanceService
    public let shiftSignupService: ShiftSignupService
    public let onboardingService: OnboardingService
    public let familyManagementService: FamilyManagementService
    public let messagingService: MessagingService
    public let scheduleGenerationService: ScheduleGenerationService
    public let leaderboardService: LeaderboardService
    public let seasonManagementService: SeasonManagementService
    public let templateManagementService: TemplateManagementService
    
    // MARK: - Initialization
    
    public init(
        initialUsers: [User] = [],
        initialHouseholds: [Household] = [],
        initialShifts: [Shift] = [],
        initialAssignments: [Assignment] = [],
        initialAttendanceRecords: [AttendanceRecord] = [],
        initialSeasons: [Season] = [],
        initialInviteCodes: [InviteCode] = [],
        initialMessages: [Message] = [],
        initialFamilyUnits: [FamilyUnit] = [],
        initialTemplates: [ShiftTemplate] = [],
        initialUserId: UserId? = nil
    ) {
        // Initialize repositories
        authRepository = InMemoryAuthRepository(initialUserId: initialUserId)
        userRepository = InMemoryUserRepository(initialUsers: initialUsers)
        householdRepository = InMemoryHouseholdRepository(initialHouseholds: initialHouseholds)
        shiftRepository = InMemoryShiftRepository(initialShifts: initialShifts)
        assignmentRepository = InMemoryAssignmentRepository(initialAssignments: initialAssignments)
        attendanceRepository = InMemoryAttendanceRepository(initialRecords: initialAttendanceRecords)
        seasonRepository = InMemorySeasonRepository(initialSeasons: initialSeasons)
        inviteCodeRepository = InMemoryInviteCodeRepository(initialInviteCodes: initialInviteCodes)
        messageRepository = InMemoryMessageRepository(initialMessages: initialMessages)
        familyUnitRepository = InMemoryFamilyUnitRepository(initialFamilyUnits: initialFamilyUnits)
        templateRepository = InMemoryTemplateRepository(initialTemplates: initialTemplates)
        
        // Initialize services with repository dependencies
        attendanceService = SimulatedAttendanceService(
            assignmentRepository: assignmentRepository,
            attendanceRepository: attendanceRepository,
            shiftRepository: shiftRepository
        )
        
        shiftSignupService = SimulatedShiftSignupService(
            assignmentRepository: assignmentRepository,
            shiftRepository: shiftRepository,
            userRepository: userRepository
        )
        
        onboardingService = SimulatedOnboardingService(
            inviteCodeRepository: inviteCodeRepository,
            userRepository: userRepository,
            householdRepository: householdRepository
        )
        
        familyManagementService = SimulatedFamilyManagementService(
            userRepository: userRepository,
            householdRepository: householdRepository,
            familyUnitRepository: familyUnitRepository
        )
        
        messagingService = SimulatedMessagingService(
            messageRepository: messageRepository,
            userRepository: userRepository,
            householdRepository: householdRepository
        )
        
        scheduleGenerationService = SimulatedScheduleGenerationService(
            shiftRepository: shiftRepository,
            templateRepository: templateRepository
        )
        
        leaderboardService = SimulatedLeaderboardService(
            attendanceRepository: attendanceRepository,
            assignmentRepository: assignmentRepository,
            userRepository: userRepository,
            shiftRepository: shiftRepository
        )
        
        seasonManagementService = SimulatedSeasonManagementService(
            seasonRepository: seasonRepository
        )
        
        templateManagementService = SimulatedTemplateManagementService(
            templateRepository: templateRepository,
            shiftRepository: shiftRepository
        )
    }
    
    // MARK: - Convenience Methods
    
    /// Clear all data from repositories (useful for testing)
    public func clearAll() {
        (authRepository as? InMemoryAuthRepository)?.clear()
        (userRepository as? InMemoryUserRepository)?.clear()
        (householdRepository as? InMemoryHouseholdRepository)?.clear()
        (shiftRepository as? InMemoryShiftRepository)?.clear()
        (assignmentRepository as? InMemoryAssignmentRepository)?.clear()
        (attendanceRepository as? InMemoryAttendanceRepository)?.clear()
        (seasonRepository as? InMemorySeasonRepository)?.clear()
        (inviteCodeRepository as? InMemoryInviteCodeRepository)?.clear()
        (messageRepository as? InMemoryMessageRepository)?.clear()
        (familyUnitRepository as? InMemoryFamilyUnitRepository)?.clear()
        (templateRepository as? InMemoryTemplateRepository)?.clear()
    }
}
