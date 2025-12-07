import Testing
@testable import Troop900Presentation

struct PlaceholderViewModelTests {

    @Test
    func initializes_with_default_title() {
        let vm = PlaceholderViewModel()
        #expect(vm.title == "Shift Scheduler")
    }
}


