import Foundation
import Troop900Domain

/// Factory methods for creating test domain entities with sensible defaults.
/// All methods allow overriding specific properties while keeping defaults for the rest.
public enum TestFixtures {
    
    // MARK: - User Fixtures
    
    /// Creates a test user with customizable properties
    public static func createUser(
        id: String = "user-\(UUID().uuidString.prefix(8))",
        email: String = "test@example.com",
        firstName: String = "Test",
        lastName: String = "User",
        role: UserRole = .parent,
        accountStatus: AccountStatus = .active,
        households: [String] = ["household-1"],
        canManageHouseholds: [String] = ["household-1"],
        familyUnitId: String? = "family-unit-1",
        isClaimed: Bool = true,
        claimCode: String? = nil,
        householdLinkCode: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) -> User {
        User(
            id: UserId(unchecked: id),
            email: email,
            firstName: firstName,
            lastName: lastName,
            role: role,
            accountStatus: accountStatus,
            households: households,
            canManageHouseholds: canManageHouseholds,
            familyUnitId: familyUnitId,
            isClaimed: isClaimed,
            claimCode: claimCode,
            householdLinkCode: householdLinkCode,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    /// Creates a parent user
    public static func createParent(
        id: String = "parent-\(UUID().uuidString.prefix(8))",
        firstName: String = "Parent",
        lastName: String = "User",
        householdId: String = "household-1"
    ) -> User {
        createUser(
            id: id,
            email: "\(id)@example.com",
            firstName: firstName,
            lastName: lastName,
            role: .parent,
            households: [householdId],
            canManageHouseholds: [householdId]
        )
    }
    
    /// Creates a scout user
    public static func createScout(
        id: String = "scout-\(UUID().uuidString.prefix(8))",
        firstName: String = "Scout",
        lastName: String = "User",
        householdId: String = "household-1",
        isClaimed: Bool = true,
        claimCode: String? = nil
    ) -> User {
        createUser(
            id: id,
            email: "\(id)@example.com",
            firstName: firstName,
            lastName: lastName,
            role: .scout,
            households: [householdId],
            canManageHouseholds: [],
            isClaimed: isClaimed,
            claimCode: claimCode
        )
    }
    
    /// Creates a committee/leadership user
    public static func createCommittee(
        id: String = "committee-\(UUID().uuidString.prefix(8))",
        firstName: String = "Committee",
        lastName: String = "Member",
        role: UserRole = .scoutmaster
    ) -> User {
        createUser(
            id: id,
            email: "\(id)@example.com",
            firstName: firstName,
            lastName: lastName,
            role: role
        )
    }
    
    // MARK: - Shift Fixtures
    
    /// Creates a test shift with customizable properties
    public static func createShift(
        id: String = "shift-\(UUID().uuidString.prefix(8))",
        date: Date = DateTestHelpers.tomorrow,
        startTime: Date? = nil,
        endTime: Date? = nil,
        requiredScouts: Int = 4,
        requiredParents: Int = 2,
        currentScouts: Int = 0,
        currentParents: Int = 0,
        location: String = "Tree Lot A",
        label: String? = "Morning Shift",
        notes: String? = nil,
        status: ShiftStatus = .published,
        seasonId: String? = "season-1",
        templateId: String? = nil,
        createdAt: Date = Date()
    ) -> Shift {
        let shiftDate = date.startOfDay
        let start = startTime ?? shiftDate.addingHours(9)
        let end = endTime ?? shiftDate.addingHours(13)
        
        return Shift(
            id: ShiftId(unchecked: id),
            date: shiftDate,
            startTime: start,
            endTime: end,
            requiredScouts: requiredScouts,
            requiredParents: requiredParents,
            currentScouts: currentScouts,
            currentParents: currentParents,
            location: location,
            label: label,
            notes: notes,
            status: status,
            seasonId: seasonId,
            templateId: templateId,
            createdAt: createdAt
        )
    }
    
    /// Creates a draft shift
    public static func createDraftShift(
        id: String = "draft-shift-\(UUID().uuidString.prefix(8))",
        date: Date = DateTestHelpers.tomorrow
    ) -> Shift {
        createShift(id: id, date: date, status: .draft)
    }
    
    /// Creates a shift that is currently in progress
    public static func createInProgressShift(
        id: String = "inprogress-shift-\(UUID().uuidString.prefix(8))"
    ) -> Shift {
        let now = Date()
        return createShift(
            id: id,
            date: now,
            startTime: now.addingHours(-1),
            endTime: now.addingHours(3)
        )
    }
    
    /// Creates a fully staffed shift
    public static func createFullShift(
        id: String = "full-shift-\(UUID().uuidString.prefix(8))",
        requiredScouts: Int = 4,
        requiredParents: Int = 2
    ) -> Shift {
        createShift(
            id: id,
            requiredScouts: requiredScouts,
            requiredParents: requiredParents,
            currentScouts: requiredScouts,
            currentParents: requiredParents
        )
    }
    
    // MARK: - Assignment Fixtures
    
    /// Creates a test assignment with customizable properties
    public static func createAssignment(
        id: String = "assignment-\(UUID().uuidString.prefix(8))",
        shiftId: String = "shift-1",
        userId: String = "user-1",
        assignmentType: AssignmentType = .parent,
        status: AssignmentStatus = .confirmed,
        notes: String? = nil,
        assignedAt: Date = Date(),
        assignedBy: String? = nil
    ) -> Assignment {
        Assignment(
            id: AssignmentId(unchecked: id),
            shiftId: ShiftId(unchecked: shiftId),
            userId: UserId(unchecked: userId),
            assignmentType: assignmentType,
            status: status,
            notes: notes,
            assignedAt: assignedAt,
            assignedBy: assignedBy.map { UserId(unchecked: $0) }
        )
    }
    
    /// Creates a walk-in assignment
    public static func createWalkInAssignment(
        id: String = "walkin-\(UUID().uuidString.prefix(8))",
        shiftId: String = "shift-1",
        userId: String = "user-1",
        addedBy: String = "committee-1"
    ) -> Assignment {
        createAssignment(
            id: id,
            shiftId: shiftId,
            userId: userId,
            assignmentType: .scout,
            notes: "Walk-in volunteer",
            assignedBy: addedBy
        )
    }
    
    // MARK: - Attendance Record Fixtures
    
    /// Creates a test attendance record with customizable properties
    public static func createAttendanceRecord(
        id: String = "attendance-\(UUID().uuidString.prefix(8))",
        assignmentId: String = "assignment-1",
        shiftId: String = "shift-1",
        userId: String = "user-1",
        checkInTime: Date? = nil,
        checkOutTime: Date? = nil,
        checkInMethod: CheckInMethod = .manual,
        checkInLocation: GeoLocation? = nil,
        hoursWorked: Double? = nil,
        status: AttendanceStatus = .pending,
        notes: String? = nil
    ) -> AttendanceRecord {
        AttendanceRecord(
            id: AttendanceRecordId(unchecked: id),
            assignmentId: AssignmentId(unchecked: assignmentId),
            shiftId: ShiftId(unchecked: shiftId),
            userId: UserId(unchecked: userId),
            checkInTime: checkInTime,
            checkOutTime: checkOutTime,
            checkInMethod: checkInMethod,
            checkInLocation: checkInLocation,
            hoursWorked: hoursWorked,
            status: status,
            notes: notes
        )
    }
    
    /// Creates a checked-in attendance record
    public static func createCheckedInRecord(
        id: String = "attendance-\(UUID().uuidString.prefix(8))",
        assignmentId: String = "assignment-1",
        shiftId: String = "shift-1",
        userId: String = "user-1",
        checkInTime: Date = Date()
    ) -> AttendanceRecord {
        createAttendanceRecord(
            id: id,
            assignmentId: assignmentId,
            shiftId: shiftId,
            userId: userId,
            checkInTime: checkInTime,
            status: .checkedIn
        )
    }
    
    /// Creates a completed attendance record
    public static func createCompletedRecord(
        id: String = "attendance-\(UUID().uuidString.prefix(8))",
        assignmentId: String = "assignment-1",
        shiftId: String = "shift-1",
        userId: String = "user-1",
        hoursWorked: Double = 4.0
    ) -> AttendanceRecord {
        let checkIn = DateTestHelpers.relativeDate(hours: -4)
        return createAttendanceRecord(
            id: id,
            assignmentId: assignmentId,
            shiftId: shiftId,
            userId: userId,
            checkInTime: checkIn,
            checkOutTime: Date(),
            hoursWorked: hoursWorked,
            status: .checkedOut
        )
    }
    
    // MARK: - Household Fixtures
    
    /// Creates a test household with customizable properties
    public static func createHousehold(
        id: String = "household-\(UUID().uuidString.prefix(8))",
        name: String = "Test Household",
        members: [String] = ["user-1"],
        managers: [String] = ["user-1"],
        familyUnits: [String] = ["family-unit-1"],
        linkCode: String? = "LINKCODE123",
        isActive: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) -> Household {
        Household(
            id: id,
            name: name,
            members: members,
            managers: managers,
            familyUnits: familyUnits,
            linkCode: linkCode,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    // MARK: - Shift Template Fixtures
    
    /// Creates a test shift template with customizable properties
    public static func createTemplate(
        id: String = "template-\(UUID().uuidString.prefix(8))",
        name: String = "Morning Shift",
        startTime: Date = DateTestHelpers.time(9, 0),
        endTime: Date = DateTestHelpers.time(13, 0),
        requiredScouts: Int = 4,
        requiredParents: Int = 2,
        location: String = "Tree Lot A",
        label: String? = "Morning",
        notes: String? = nil,
        isActive: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) -> ShiftTemplate {
        ShiftTemplate(
            id: id,
            name: name,
            startTime: startTime,
            endTime: endTime,
            requiredScouts: requiredScouts,
            requiredParents: requiredParents,
            location: location,
            label: label,
            notes: notes,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    // MARK: - Season Fixtures
    
    /// Creates a test season with customizable properties
    public static func createSeason(
        id: String = "season-\(UUID().uuidString.prefix(8))",
        name: String = "2024 Tree Lot",
        year: Int = 2024,
        startDate: Date = DateTestHelpers.seasonStartDate,
        endDate: Date = DateTestHelpers.seasonEndDate,
        status: SeasonStatus = .active,
        description: String? = "Annual Christmas tree lot fundraiser",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) -> Season {
        Season(
            id: id,
            name: name,
            year: year,
            startDate: startDate,
            endDate: endDate,
            status: status,
            description: description,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    /// Creates a draft season
    public static func createDraftSeason(
        id: String = "draft-season-\(UUID().uuidString.prefix(8))"
    ) -> Season {
        createSeason(id: id, status: .draft)
    }
    
    // MARK: - Invite Code Fixtures
    
    /// Creates a test invite code with customizable properties
    public static func createInviteCode(
        id: String = "invite-\(UUID().uuidString.prefix(8))",
        code: String = "TESTCODE",
        householdId: String = "household-1",
        role: UserRole = .parent,
        createdBy: String = "admin-1",
        usedBy: String? = nil,
        usedAt: Date? = nil,
        expiresAt: Date? = nil,
        isUsed: Bool = false,
        createdAt: Date = Date()
    ) -> InviteCode {
        InviteCode(
            id: id,
            code: code,
            householdId: householdId,
            role: role,
            createdBy: createdBy,
            usedBy: usedBy,
            usedAt: usedAt,
            expiresAt: expiresAt,
            isUsed: isUsed,
            createdAt: createdAt
        )
    }
    
    /// Creates an expired invite code
    public static func createExpiredInviteCode(
        id: String = "expired-invite-\(UUID().uuidString.prefix(8))",
        code: String = "EXPIRED"
    ) -> InviteCode {
        createInviteCode(
            id: id,
            code: code,
            expiresAt: DateTestHelpers.yesterday
        )
    }
    
    /// Creates an already used invite code
    public static func createUsedInviteCode(
        id: String = "used-invite-\(UUID().uuidString.prefix(8))",
        code: String = "USEDCODE"
    ) -> InviteCode {
        createInviteCode(
            id: id,
            code: code,
            usedBy: "user-1",
            usedAt: Date(),
            isUsed: true
        )
    }
    
    // MARK: - Message Fixtures
    
    /// Creates a test message with customizable properties
    public static func createMessage(
        id: String = "message-\(UUID().uuidString.prefix(8))",
        title: String = "Test Message",
        body: String = "This is a test message body.",
        targetAudience: TargetAudience = .all,
        targetUserIds: [String]? = nil,
        targetHouseholdIds: [String]? = nil,
        senderId: String = "admin-1",
        sentAt: Date = Date(),
        priority: MessagePriority = .normal,
        isRead: Bool = false
    ) -> Message {
        Message(
            id: id,
            title: title,
            body: body,
            targetAudience: targetAudience,
            targetUserIds: targetUserIds,
            targetHouseholdIds: targetHouseholdIds,
            senderId: senderId,
            sentAt: sentAt,
            priority: priority,
            isRead: isRead
        )
    }
    
    // MARK: - Family Unit Fixtures
    
    /// Creates a test family unit with customizable properties
    public static func createFamilyUnit(
        id: String = "family-unit-\(UUID().uuidString.prefix(8))",
        householdId: String = "household-1",
        scouts: [String] = ["scout-1"],
        parents: [String] = ["parent-1"],
        name: String? = "Smith Family",
        createdAt: Date = Date()
    ) -> FamilyUnit {
        FamilyUnit(
            id: id,
            householdId: householdId,
            scouts: scouts,
            parents: parents,
            name: name,
            createdAt: createdAt
        )
    }
    
    // MARK: - GeoLocation Fixtures
    
    /// Creates a test GeoLocation (Tree Lot A coordinates)
    public static func createLocation(
        latitude: Double = 37.7749,
        longitude: Double = -122.4194
    ) -> GeoLocation {
        GeoLocation(latitude: latitude, longitude: longitude)
    }
}
