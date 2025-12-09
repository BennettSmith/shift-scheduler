import Foundation
import Troop900Domain

/// Protocol for getting the current authenticated user.
public protocol GetCurrentUserUseCaseProtocol: Sendable {
    func execute() async throws -> CurrentUserResponse
}

/// Use case for retrieving the current authenticated user's information.
public final class GetCurrentUserUseCase: GetCurrentUserUseCaseProtocol, Sendable {
    private let authRepository: AuthRepository
    private let userRepository: UserRepository
    private let householdRepository: HouseholdRepository
    
    public init(
        authRepository: AuthRepository,
        userRepository: UserRepository,
        householdRepository: HouseholdRepository
    ) {
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.householdRepository = householdRepository
    }
    
    public func execute() async throws -> CurrentUserResponse {
        guard let userId = authRepository.currentUserId else {
            throw DomainError.notAuthenticated
        }
        
        let user = try await userRepository.getUser(id: userId)
        
        // Fetch all households the user belongs to
        var households: [HouseholdInfo] = []
        for householdId in user.households {
            if let household = try? await householdRepository.getHousehold(id: householdId) {
                households.append(HouseholdInfo(from: household))
            }
        }
        
        return CurrentUserResponse(
            user: UserInfo(from: user),
            households: households
        )
    }
}
