import Foundation
import Troop900Domain

/// Protocol for getting the leaderboard.
public protocol GetLeaderboardUseCaseProtocol: Sendable {
    func execute(seasonId: String?) async throws -> LeaderboardResult
}

/// Use case for retrieving the leaderboard.
public final class GetLeaderboardUseCase: GetLeaderboardUseCaseProtocol, Sendable {
    private let leaderboardService: LeaderboardService
    
    public init(leaderboardService: LeaderboardService) {
        self.leaderboardService = leaderboardService
    }
    
    public func execute(seasonId: String?) async throws -> LeaderboardResult {
        try await leaderboardService.getLeaderboard(seasonId: seasonId)
    }
}
