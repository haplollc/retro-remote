import XCTest

final class RetroRemoteUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testLaunchDarkMode() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-UIUserInterfaceStyle", "Dark"]
        app.launch()
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen - Dark Mode"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testLaunchLightMode() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-UIUserInterfaceStyle", "Light"]
        app.launch()
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen - Light Mode"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
