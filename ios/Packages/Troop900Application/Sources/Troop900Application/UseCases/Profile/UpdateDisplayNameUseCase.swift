import Foundation
import Troop900Domain

/// Protocol for updating display name.
public protocol UpdateDisplayNameUseCaseProtocol: Sendable {
    func execute(request: UpdateDisplayNameRequest) async throws
}

/// Use case for updating a user's display name.
/// Used by UC 46 for users to correct or update their name.
public final class UpdateDisplayNameUseCase: UpdateDisplayNameUseCaseProtocol, Sendable {
    private let userRepository: UserRepository
    
    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    public func execute(request: UpdateDisplayNameRequest) async throws {
        // Validate and convert boundary ID to domain ID type
        let userId = try UserId(request.userId)
        
        // Validate user exists
        let user = try await userRepository.getUser(id: userId)
        
        // Validate names are not empty
        let trimmedFirstName = request.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLastName = request.lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedFirstName.isEmpty else {
            throw DomainError.invalidInput("First name cannot be empty")
        }
        
        guard !trimmedLastName.isEmpty else {
            throw DomainError.invalidInput("Last name cannot be empty")
        }
        
        // Validate name length (max 50 characters each)
        guard trimmedFirstName.count <= 50 else {
            throw DomainError.invalidInput("First name is too long (max 50 characters)")
        }
        
        guard trimmedLastName.count <= 50 else {
            throw DomainError.invalidInput("Last name is too long (max 50 characters)")
        }
        
        // Create updated user with new name
        let updatedUser = User(
            id: user.id,
            email: user.email,
            firstName: trimmedFirstName,
            lastName: trimmedLastName,
            role: user.role,
            accountStatus: user.accountStatus,
            households: user.households,
            canManageHouseholds: user.canManageHouseholds,
            familyUnitId: user.familyUnitId,
            isClaimed: user.isClaimed,
            claimCode: user.claimCode,
            householdLinkCode: user.householdLinkCode,
            createdAt: user.createdAt,
            updatedAt: Date()
        )
        
        try await userRepository.updateUser(updatedUser)
    }
}
