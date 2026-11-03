import XCTest

/// On-device end-to-end checks for the sprint-surfaces system integrations (FEAT-06/07/08).
/// Run on "lexpresswayyy" (Siri + Spotlight need a real device). Creates one uniquely named test alarm and
/// deletes it at the end.
final class SystemSurfacesUITests: XCTestCase {
    private let app = XCUIApplication()
    private let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    private let title = "Zeta Test \(["Kilo", "Lima", "Oscar", "Romeo", "Sierra", "Tango"].randomElement()!)"

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["-hasCompletedOnboarding", "YES"]
        app.launch()
        while deleteAlarm(labelPrefix: "Zeta Test") {} // leftovers from an interrupted run
    }

    override func tearDownWithError() throws {
        app.activate()
        let notNow = springboard.buttons["Not Now"] // App Store rating prompt triggered by completions
        if notNow.waitForExistence(timeout: 3) { notNow.tap() }
        if !app.navigationBars["Alarms"].exists, app.navigationBars.buttons.firstMatch.exists {
            app.navigationBars.buttons.firstMatch.tap() // back out of detail
        }
        _ = deleteAlarm(labelPrefix: title)
    }

    @MainActor
    func testDeepLinkCreateAndSiriMarkDone() throws {
        // FEAT-07 — the "New Alarm" control opens chronir://new.
        openURL("chronir://new")
        let nameField = app.textFields["Alarm Name"] // LabeledTextField labels its TextField with `label`
        XCTAssertTrue(nameField.waitForExistence(timeout: 10), "chronir://new didn't open creation")
        attachScreenshot("00-creation-from-deeplink")
        let closeTip = app.buttons["Close"]
        if closeTip.waitForExistence(timeout: 2) { closeTip.tap() } // a TipKit popover may be showing
        nameField.tap()
        nameField.typeText(title)
        app.buttons["Save"].tap()
        allowSystemAlerts()
        let row = alarmRow(labelPrefix: title)
        XCTAssertTrue(row.waitForExistence(timeout: 10), "Created alarm not in list")
        attachScreenshot("01-created")

        // FEAT-08 indexing is covered by CompleteAlarmIntentTests.spotlightIndexRoundTrip(); Spotlight's own
        // result ranking (web suggestions first) isn't deterministic enough to drive here.
        sleep(30) // Siri registers new App Shortcut parameter values (alarm names) asynchronously

        // FEAT-06 — Siri marks it done; verify the effect in Chronir (the row's "Next <date>" jumps a cycle).
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        let before = row.label
        XCTAssertTrue(before.contains("Next "), "Row label has no next fire date: \(before)")
        XCUIDevice.shared.siriService.activate(voiceRecognitionText: "Mark an alarm as done in Chronir")
        sleep(5) // Siri asks "Which alarm?"
        let ask = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        ask.name = "04-siri-which-alarm"
        ask.lifetime = .keepAlways
        add(ask)
        XCUIDevice.shared.siriService.activate(voiceRecognitionText: title)
        for step in 1...6 { // Siri resolves the alarm, runs the intent, replies
            sleep(2)
            let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot()) // full screen, includes Siri's UI
            shot.lifetime = .keepAlways
            add(shot)
            _ = step
        }
        app.activate()
        let changed = NSPredicate(format: "label != %@", before)
        expectation(for: changed, evaluatedWith: row)
        waitForExpectations(timeout: 15)
        attachScreenshot("05-after-siri")
        XCTAssertNotEqual(row.label, before, "Siri didn't advance the alarm")
    }

    // MARK: - Helpers

    private func openURL(_ string: String) {
        guard let url = URL(string: string) else { return XCTFail("bad URL \(string)") }
        XCUIDevice.shared.system.open(url)
        let open = springboard.buttons["Open"]
        if open.waitForExistence(timeout: 2) { open.tap() }
    }

    /// Accepts first-run permission prompts (notifications / alarms) if they appear.
    private func allowSystemAlerts() {
        for label in ["Allow", "Allow While Using App", "OK"] {
            let button = springboard.alerts.buttons[label]
            if button.waitForExistence(timeout: 2) { button.tap() }
        }
    }

    /// An alarm list row is one button-type element whose label starts with the alarm title
    /// ("<title>, <schedule>, ..., Next <date>") — see AlarmListRow.accessibilityLabel.
    private func alarmRow(labelPrefix: String) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", labelPrefix)).firstMatch
    }

    /// Deletes the first alarm whose title starts with `labelPrefix`. Returns false when none is left.
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

    private func attachScreenshot(_ name: String, from source: XCUIApplication? = nil) {
        let shot = XCTAttachment(screenshot: (source ?? app).screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
