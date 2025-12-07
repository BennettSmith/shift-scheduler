import Foundation
import Troop900Domain

/// Protocol for generating invite codes.
public protocol GenerateInviteCodesUseCaseProtocol: Sendable {
    func execute(request: GenerateInviteCodesRequest) async throws -> GenerateInviteCodesResponse
}

/// Use case for generating invite codes for a household.
public final class GenerateInviteCodesUseCase: GenerateInviteCodesUseCaseProtocol, Sendable {
    private let inviteCodeRepository: InviteCodeRepository
    
    public init(inviteCodeRepository: InviteCodeRepository) {
        self.inviteCodeRepository = inviteCodeRepository
    }
    
    public func execute(request: GenerateInviteCodesRequest) async throws -> GenerateInviteCodesResponse {
        var generatedCodes: [InviteCode] = []
        let expirationDate = request.expirationDays.map { days in
            Calendar.current.date(byAdding: .day, value: days, to: Date())
        }
        
        for _ in 0..<request.count {
            let code = generateRandomCode()
            let inviteCode = InviteCode(
                id: UUID().uuidString,
                code: code,
                householdId: request.householdId,
                role: request.role,
                createdBy: "", // Should be set from auth context
                usedBy: nil,
                usedAt: nil,
                expiresAt: expirationDate.flatMap { $0 },
                isUsed: false,
                createdAt: Date()
            )
            
            let _ = try await inviteCodeRepository.createInviteCode(inviteCode)
            generatedCodes.append(inviteCode)
        }
        
        return GenerateInviteCodesResponse(
            codes: generatedCodes,
            message: "Generated \(request.count) invite code(s)"
        )
    }
    
    private func generateRandomCode() -> String {
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<8).map { _ in characters.randomElement()! })
    }
}
