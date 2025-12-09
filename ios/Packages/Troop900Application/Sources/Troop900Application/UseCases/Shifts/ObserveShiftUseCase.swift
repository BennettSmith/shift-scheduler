import Foundation
import Troop900Domain

/// Protocol for observing a shift in real-time.
public protocol ObserveShiftUseCaseProtocol: Sendable {
    func execute(shiftId: String) -> AsyncThrowingStream<Shift, Error>
}

/// Use case for observing real-time updates to a shift.
public final class ObserveShiftUseCase: ObserveShiftUseCaseProtocol, Sendable {
    private let shiftRepository: ShiftRepository
    
    public init(shiftRepository: ShiftRepository) {
        self.shiftRepository = shiftRepository
    }
    
    public func execute(shiftId: String) -> AsyncThrowingStream<Shift, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    // Validate and convert boundary ID to domain ID type
                    let shiftIdValue = try ShiftId(shiftId)
                    
                    for try await shift in shiftRepository.observeShift(id: shiftIdValue) {
                        continuation.yield(shift)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
}
