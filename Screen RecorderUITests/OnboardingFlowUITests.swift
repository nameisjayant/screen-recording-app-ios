import XCTest

final class OnboardingFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCompletingOnboardingLandsOnHome() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()

        let primary = app.buttons["onboarding.primary"]
        XCTAssertTrue(primary.waitForExistence(timeout: 6))
        primary.tap()
        primary.tap()
        primary.tap()

        XCTAssertTrue(app.staticTexts["home.title"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testSkipLandsOnHome() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()

        let skip = app.buttons["onboarding.skip"]
        XCTAssertTrue(skip.waitForExistence(timeout: 6))
        skip.tap()

        XCTAssertTrue(app.staticTexts["home.title"].waitForExistence(timeout: 3))
    }
}
