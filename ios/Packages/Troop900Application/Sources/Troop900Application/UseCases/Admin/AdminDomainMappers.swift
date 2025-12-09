import Foundation
import Troop900Domain

// MARK: - UserRoleType toDomain (also in AttendanceDomainMappers)

extension UserRoleType {
    func toDomain() -> UserRole {
        switch self {
        case .scout:
            return .scout
        case .parent:
            return .parent
        case .scoutmaster:
            return .scoutmaster
        case .assistantScoutmaster:
            return .assistantScoutmaster
        }
    }
}

// MARK: - InviteCodeInfo Mapping

extension InviteCodeInfo {
    init(from inviteCode: InviteCode) {
        self.init(
            code: inviteCode.code,
            role: UserRoleType(from: inviteCode.role),
            expiresAt: inviteCode.expiresAt,
            createdAt: inviteCode.createdAt
        )
    }
}
