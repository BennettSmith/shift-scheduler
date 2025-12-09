import Foundation
import Troop900Domain

// MARK: - AccountStatusType Mapping
// Note: UserRoleType mapping is in AttendanceDomainMappers.swift

extension AccountStatusType {
    init(from domain: AccountStatus) {
        switch domain {
        case .pending:
            self = .pending
        case .active:
            self = .active
        case .inactive:
            self = .inactive
        case .deactivated:
            self = .deactivated
        }
    }
    
    func toDomain() -> AccountStatus {
        switch self {
        case .pending:
            return .pending
        case .active:
            return .active
        case .inactive:
            return .inactive
        case .deactivated:
            return .deactivated
        }
    }
}

// MARK: - UserInfo Mapping

extension UserInfo {
    init(from user: User) {
        self.init(
            id: user.id.value,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            fullName: user.fullName,
            role: UserRoleType(from: user.role),
            accountStatus: AccountStatusType(from: user.accountStatus),
            householdIds: user.households,
            canManageHouseholdIds: user.canManageHouseholds,
            familyUnitId: user.familyUnitId,
            isClaimed: user.isClaimed,
            isAdmin: user.isAdmin,
            canSignUpForShifts: user.canSignUpForShifts
        )
    }
}

// MARK: - HouseholdInfo Mapping

extension HouseholdInfo {
    init(from household: Household) {
        self.init(
            id: household.id,
            name: household.name,
            memberCount: household.members.count,
            isActive: household.isActive,
            linkCode: household.linkCode
        )
    }
}
