import XCTest

/// On-device release drive for the alarm-engine fixes in v1.3.1 (BUG-08, BUG-10, BUG-11).
/// Run on "lexpresswayyy" only: AlarmKit must really fire. Each test waits for real alarm times, so the
/// suite takes ~12 minutes. Creates "Zeta Drive" alarms and deletes them at the end.
final class ReleaseDriveUITests: XCTestCase {
    private let app = XCUIApplication()
    private let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["-hasCompletedOnboarding", "YES"]
        app.launch()
        stopFiringIfNeeded()
        while deleteAlarm(labelPrefix: "Zeta Drive") {}
    }

    override func tearDownWithError() throws {
        app.activate()
        stopFiringIfNeeded()
        while deleteAlarm(labelPrefix: "Zeta Drive") {}
    }

    /// BUG-11: an alarm that fires while the app is killed must still be ringing after a cold launch.
    /// BUG-08: stop it, edit the time to the next minute within 10 s, force-quit; the edited time must ring.
    @MainActor
    func testKilledAppFireSurvivesLaunchAndEditAfterStopRings() throws {
        let title = "Zeta Drive Kill"
        let fire = Self.minute(after: 2)
        createAlarm(title: title, times: [fire])
        attachScreenshot("bug11-00-created")

        app.terminate()
        Self.sleep(until: fire.addingTimeInterval(12))
        app.launch()
        XCTAssertTrue(firingScreen.waitForExistence(timeout: 20), "BUG-11: no firing screen after cold launch")
        attachScreenshot("bug11-01-firing-after-cold-launch")
        Thread.sleep(forTimeInterval: 8) // the reschedule on launch used to cancel it right here
        XCTAssertTrue(firingScreen.exists, "BUG-11: firing screen vanished after launch reschedule")
        attachScreenshot("bug11-02-still-firing-8s-later")

        // BUG-08 candidate 2: stop, then edit to the next minute within 10 s, then force-quit.
        let next = Self.minute(after: 1)
        stopFiring()
        editFirstTime(ofAlarm: title, to: next)
        attachScreenshot("bug08-00-edited-after-stop")
        app.terminate()
        Self.sleep(until: next.addingTimeInterval(12))
        app.launch()
        XCTAssertTrue(firingScreen.waitForExistence(timeout: 20), "BUG-08: edited alarm did not ring")
        attachScreenshot("bug08-01-edited-time-rang")
        stopFiring()
    }

    /// BUG-10: editing a two-time alarm down to one time; the removed time must not ring, the kept one must.
    @MainActor
    func testRemovedTimeSlotDoesNotRing() throws {
        let title = "Zeta Drive Slots"
        let removed = Self.minute(after: 2)
        let kept = Self.minute(after: 4)
        createAlarm(title: title, times: [removed, kept])
        attachScreenshot("bug10-00-two-times")

        openAlarm(title)
        let chip = app.buttons["Remove \(Self.chipLabel(removed))"]
        XCTAssertTrue(chip.waitForExistence(timeout: 5), "No remove button for \(Self.chipLabel(removed))")
        chip.tap()
        app.buttons["Save"].tap()
        attachScreenshot("bug10-01-one-time")

        Self.sleep(until: removed.addingTimeInterval(40))
        XCTAssertFalse(firingScreen.exists, "BUG-10: the removed time rang")
        attachScreenshot("bug10-02-removed-time-silent")

        Self.sleep(until: kept.addingTimeInterval(5))
        XCTAssertTrue(firingScreen.waitForExistence(timeout: 30), "BUG-10: the kept time did not ring")
        attachScreenshot("bug10-03-kept-time-rang")
        stopFiring()
    }

    // MARK: - Drive helpers

    /// "Mark as Done" (tap) or, with Slide to Stop on, the hold button labelled "Mark as done".
    private var firingScreen: XCUIElement {
        app.buttons.matching(NSPredicate(format: "label ==[c] 'Mark as Done'")).firstMatch
    }

    private func createAlarm(title: String, times: [Date]) {
        let nameField = app.textFields["Alarm Name"]
        app.buttons["New Alarm"].tap()
        if !nameField.waitForExistence(timeout: 5) { // a TipKit popover can eat the first tap
            let closeTip = app.buttons["Close"]
            if closeTip.waitForExistence(timeout: 2) { closeTip.tap() }
            app.buttons["New Alarm"].tap()
        }
        XCTAssertTrue(nameField.waitForExistence(timeout: 10), "Creation sheet did not open")
        let closeTip = app.buttons["Close"]
        if closeTip.waitForExistence(timeout: 2) { closeTip.tap() }
        nameField.tap()
        nameField.typeText(title)
        app.buttons[Self.todayName].tap() // weekly alarms default to Monday only

        let defaultChip = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Alarm time '")).firstMatch
        XCTAssertTrue(defaultChip.waitForExistence(timeout: 5))
        defaultChip.tap()
        setWheels(to: times[0])
        app.buttons["Done"].tap()
        for time in times.dropFirst() {
            app.buttons["Add alarm time"].tap()
            setWheels(to: time)
            app.buttons["Add"].tap()
        }
        app.buttons["Save"].tap()
        allowSystemAlerts()
        XCTAssertTrue(alarmRow(labelPrefix: title).waitForExistence(timeout: 10), "Created alarm not in list")
    }

    private func openAlarm(_ title: String) {
        let row = alarmRow(labelPrefix: title)
        XCTAssertTrue(row.waitForExistence(timeout: 10))
        row.tap()
        XCTAssertTrue(app.navigationBars["Edit Alarm"].waitForExistence(timeout: 10), "Detail did not open")
    }

    private func editFirstTime(ofAlarm title: String, to date: Date) {
        openAlarm(title)
        let chip = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Alarm time '")).firstMatch
        XCTAssertTrue(chip.waitForExistence(timeout: 5))
        chip.tap()
        setWheels(to: date)
        app.buttons["Done"].tap()
        app.buttons["Save"].tap()
        XCTAssertTrue(alarmRow(labelPrefix: title).waitForExistence(timeout: 10))
    }

    private func setWheels(to date: Date) {
        let picker = app.datePickers.firstMatch
        XCTAssertTrue(picker.waitForExistence(timeout: 5), "Time wheel sheet did not open")
        let wheels = picker.pickerWheels
        let fmt = DateFormatter()
        fmt.dateFormat = "h"
        wheels.element(boundBy: 0).adjust(toPickerWheelValue: fmt.string(from: date))
        fmt.dateFormat = "mm"
        wheels.element(boundBy: 1).adjust(toPickerWheelValue: fmt.string(from: date))
        if wheels.count > 2 {
            fmt.dateFormat = "a"
            wheels.element(boundBy: 2).adjust(toPickerWheelValue: fmt.string(from: date))
        }
    }

    private func stopFiring() {
        XCTAssertTrue(firingScreen.waitForExistence(timeout: 5))
        firingScreen.press(forDuration: 3.5) // long enough for the hold button; a plain button ignores the extra
        let notNow = springboard.buttons["Not Now"] // App Store rating prompt after completions
        if notNow.waitForExistence(timeout: 3) { notNow.tap() }
        XCTAssertTrue(app.navigationBars["Alarms"].waitForExistence(timeout: 10), "Firing screen did not close")
    }

    private func stopFiringIfNeeded() {
        if firingScreen.waitForExistence(timeout: 3) { stopFiring() }
    }

    private func allowSystemAlerts() {
        for label in ["Allow", "Allow While Using App", "OK"] {
            let button = springboard.alerts.buttons[label]
            if button.waitForExistence(timeout: 2) { button.tap() }
        }
    }

    private func alarmRow(labelPrefix: String) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", labelPrefix)).firstMatch
    }

    @discardableResult
    private func deleteAlarm(labelPrefix: String) -> Bool {
        let row = alarmRow(labelPrefix: labelPrefix)
        guard row.waitForExistence(timeout: 3) else { return false }
        row.swipeLeft()
        let swipeDelete = app.buttons["Delete"]
        guard swipeDelete.waitForExistence(timeout: 3) else { return false }
        swipeDelete.tap()
        let confirm = app.alerts.buttons["Delete"]
        guard confirm.waitForExistence(timeout: 3) else { return false }
        confirm.tap()
        return true
    }

    private func attachScreenshot(_ name: String) {
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }

    // MARK: - Time helpers

    /// The next minute boundary plus `minutes`.
    private static func minute(after minutes: Int) -> Date {
        let cal = Calendar.current
        let parts = cal.dateComponents([.year, .month, .day, .hour, .minute], from: Date().addingTimeInterval(60))
        return cal.date(byAdding: .minute, value: minutes, to: cal.date(from: parts)!)!
    }

    private static func sleep(until date: Date) {
        let interval = date.timeIntervalSinceNow
        if interval > 0 { Thread.sleep(forTimeInterval: interval) }
    }

    /// Matches `TimeOfDay.formatted` (shortened time).
    private static func chipLabel(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }

    private static var todayName: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEE"
        return fmt.string(from: Date())
    }
}
