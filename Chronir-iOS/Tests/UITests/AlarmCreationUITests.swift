import XCTest

final class AlarmCreationUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    func testAlarmCreationFlow() {
        // TODO: Implement in Sprint 1
        // 1. Tap "+" button to open creation sheet
        // 2. Enter alarm title
        // 3. Select cycle type
        // 4. Set time
        // 5. Tap Save
        // 6. Verify alarm appears in list
    }

    func testAlarmCreationValidation() {
        // TODO: Implement in Sprint 1
        // 1. Open creation sheet
        // 2. Leave title empty
        // 3. Tap Save
        // 4. Verify validation error is shown
    }

    func testAlarmCreationCancel() {
        // TODO: Implement in Sprint 1
        // 1. Open creation sheet
        // 2. Fill in some fields
        // 3. Tap Cancel
        // 4. Verify sheet is dismissed and no alarm was created
    }
}
