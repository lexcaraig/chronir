import XCTest

/// On-device end-to-end checks for the sprint-surfaces system integrations (FEAT-06/07/08).
/// Run on "lexpresswayyy" (Siri + Spotlight need a real device). Creates one uniquely named test alarm and
/// deletes it at the end.
final class SystemSurfacesUITests: XCTestCase {
    private let app = XCUIApplication()
    private let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    private let title = "Zeta Test \(Int.random(in: 1000...9999))"

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["-hasCompletedOnboarding", "YES"]
        app.launch()
    }

    override func tearDownWithError() throws {
        deleteTestAlarmIfPresent()
    }

    @MainActor
    func testDeepLinkSpotlightAndSiri() throws {
        // FEAT-07 — the "New Alarm" control opens chronir://new.
        openURL("chronir://new")
        XCTAssertTrue(app.staticTexts["New Alarm"].waitForExistence(timeout: 10), "chronir://new didn't open creation")

        let nameField = app.textFields["Enter a name..."]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        nameField.typeText(title)
        app.buttons["Save"].tap()
        allowSystemAlerts()
        XCTAssertTrue(app.staticTexts[title].waitForExistence(timeout: 10), "Created alarm not in list")
        attachScreenshot("01-created")

        // FEAT-08 — Spotlight finds the alarm and opens it.
        sleep(3) // let WidgetDataService.refresh() re-index
        XCUIDevice.shared.press(.home)
        springboard.swipeDown(velocity: .slow)
        let search = springboard.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 5), "Spotlight search field didn't appear")
        search.typeText(title)
        let result = springboard.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS %@", title)).firstMatch
        XCTAssertTrue(result.waitForExistence(timeout: 10), "Spotlight didn't find \(title)")
        attachScreenshot("02-spotlight", from: springboard)
        result.tap()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10), "Spotlight result didn't open Chronir")
        XCTAssertTrue(app.staticTexts[title].waitForExistence(timeout: 10), "Alarm not shown after Spotlight tap")
        attachScreenshot("03-opened-from-spotlight")

        // FEAT-06 — Siri marks it done.
        XCUIDevice.shared.siriService.activate(voiceRecognitionText: "Mark \(title) as done in Chronir")
        let siri = XCUIApplication(bundleIdentifier: "com.apple.siri")
        let reply = siri.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS[c] %@", "as done")).firstMatch
        let replied = reply.waitForExistence(timeout: 20)
        attachScreenshot("04-siri", from: siri)
        XCTAssertTrue(replied, "No 'Marked … as done' reply from Siri")
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

    private func deleteTestAlarmIfPresent() {
        app.activate()
        if app.navigationBars.buttons.firstMatch.exists, !app.staticTexts["Alarms"].exists {
            app.navigationBars.buttons.firstMatch.tap() // back out of detail
        }
        let row = app.staticTexts[title]
        guard row.waitForExistence(timeout: 5) else { return }
        row.swipeLeft()
        let delete = app.buttons["Delete"]
        guard delete.waitForExistence(timeout: 3) else { return }
        delete.tap()
        let confirm = app.buttons.matching(identifier: "Delete").element(boundBy: 0)
        if confirm.waitForExistence(timeout: 3) { confirm.tap() }
    }

    private func attachScreenshot(_ name: String, from source: XCUIApplication? = nil) {
        let shot = XCTAttachment(screenshot: (source ?? app).screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
