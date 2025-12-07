import Testing
@testable import Troop900Domain

@Suite("AttendanceStatus Tests")
struct AttendanceStatusTests {
    
    @Test("Display names are correct")
    func displayNames() {
        #expect(AttendanceStatus.pending.displayName == "Pending")
        #expect(AttendanceStatus.checkedIn.displayName == "Checked In")
        #expect(AttendanceStatus.checkedOut.displayName == "Completed")
        #expect(AttendanceStatus.noShow.displayName == "No Show")
        #expect(AttendanceStatus.excused.displayName == "Excused")
    }
    
    @Test("Checked out is complete")
    func checkedOutIsComplete() {
        #expect(AttendanceStatus.checkedOut.isComplete)
    }
    
    @Test("No show is complete")
    func noShowIsComplete() {
        #expect(AttendanceStatus.noShow.isComplete)
    }
    
    @Test("Excused is complete")
    func excusedIsComplete() {
        #expect(AttendanceStatus.excused.isComplete)
    }
    
    @Test("Pending is not complete")
    func pendingIsNotComplete() {
        #expect(!AttendanceStatus.pending.isComplete)
    }
    
    @Test("Checked in is not complete")
    func checkedInIsNotComplete() {
        #expect(!AttendanceStatus.checkedIn.isComplete)
    }
    
    @Test("Raw values")
    func rawValues() {
        #expect(AttendanceStatus.pending.rawValue == "pending")
        #expect(AttendanceStatus.checkedIn.rawValue == "checked_in")
        #expect(AttendanceStatus.checkedOut.rawValue == "checked_out")
        #expect(AttendanceStatus.noShow.rawValue == "no_show")
        #expect(AttendanceStatus.excused.rawValue == "excused")
    }
}
