import Foundation

/// Protocol for observing shift assignments in real-time.
public protocol ObserveShiftAssignmentsUseCaseProtocol: Sendable {
    func execute(shiftId: String) -> AsyncThrowingStream<[AssignmentInfo], Error>
}

/// Use case for observing real-time updates to shift assignments.
public final class ObserveShiftAssignmentsUseCase: ObserveShiftAssignmentsUseCaseProtocol, Sendable {
    private let assignmentRepository: AssignmentRepository
    private let userRepository: UserRepository
    
    public init(assignmentRepository: AssignmentRepository, userRepository: UserRepository) {
        self.assignmentRepository = assignmentRepository
        self.userRepository = userRepository
    }
    
    public func execute(shiftId: String) -> AsyncThrowingStream<[AssignmentInfo], Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await assignments in assignmentRepository.observeAssignmentsForShift(shiftId: shiftId) {
                        var assignmentInfos: [AssignmentInfo] = []
                        
                        for assignment in assignments where assignment.isActive {
                            if let user = try? await userRepository.getUser(id: assignment.userId) {
                                assignmentInfos.append(AssignmentInfo(
                                    id: assignment.id,
                                    userId: assignment.userId,
                                    userName: user.fullName,
                                    assignmentType: assignment.assignmentType,
                                    status: assignment.status,
                                    notes: assignment.notes,
                                    assignedAt: assignment.assignedAt
                                ))
                            }
                        }
                        
                        continuation.yield(assignmentInfos)
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
