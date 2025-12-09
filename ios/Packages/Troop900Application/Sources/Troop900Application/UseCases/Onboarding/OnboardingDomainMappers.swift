import Foundation
import Troop900Domain

// MARK: - ClaimedProfileInfo Mapping

extension ClaimedProfileInfo {
    init(from user: User) {
        self.init(
            userId: user.id.value,
            firstName: user.firstName,
            lastName: user.lastName,
            fullName: user.fullName,
            role: UserRoleType(from: user.role),
            householdIds: user.households
        )
    }
}
