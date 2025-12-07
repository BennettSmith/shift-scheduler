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
        shiftRepository.observeShift(id: shiftId)
    }
}
