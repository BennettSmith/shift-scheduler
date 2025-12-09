import Foundation
import Troop900Domain

// MARK: - MemberInfo Mapping

extension MemberInfo {
    init(from user: User) {
        self.init(
            id: user.id.value,
            firstName: user.firstName,
            lastName: user.lastName,
            fullName: user.fullName,
            role: UserRoleType(from: user.role),
            isClaimed: user.isClaimed
        )
    }
}

// MARK: - FamilyUnitInfo Mapping

extension FamilyUnitInfo {
    init(from familyUnit: FamilyUnit) {
        self.init(
            id: familyUnit.id,
            name: familyUnit.name,
            scoutIds: familyUnit.scouts,
            parentIds: familyUnit.parents
        )
    }
}
