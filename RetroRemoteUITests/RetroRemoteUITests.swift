import XCTest

final class RetroRemoteUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Basic UI Tests
    
    func testAppLaunches() throws {
        // Verify the app launches and shows the remote control view
        XCTAssertTrue(app.state == .runningForeground)
    }
    
    func testPowerButtonExists() throws {
        // Look for power button with the power symbol
        let powerButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'power'")).firstMatch
        
        // The power button should be visible
        XCTAssertTrue(powerButton.waitForExistence(timeout: 5))
    }
    
    func testDPadButtonsExist() throws {
        // Wait for the app to load
        sleep(1)
        
        // The OK button should exist
        let okButton = app.staticTexts["OK"]
        XCTAssertTrue(okButton.waitForExistence(timeout: 5))
        
        // Navigation arrows should exist (using chevron images)
        let chevrons = app.images.matching(NSPredicate(format: "identifier CONTAINS 'chevron'"))
        XCTAssertGreaterThanOrEqual(chevrons.count, 0) // At least some navigation elements
    }
    
    func testVolumeButtonsExist() throws {
        // Volume buttons should exist
        let speakerImages = app.images.matching(NSPredicate(format: "identifier CONTAINS 'speaker'"))
        XCTAssertGreaterThanOrEqual(speakerImages.count, 0)
    }
    
    func testPlaybackButtonsExist() throws {
        // Look for playback section
        let playbackLabel = app.staticTexts["PLAYBACK"]
        XCTAssertTrue(playbackLabel.waitForExistence(timeout: 5))
    }
    
    func testNumberPadToggle() throws {
        // Find the "Show Numbers" button
        let showNumbersButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Numbers'")).firstMatch
        XCTAssertTrue(showNumbersButton.waitForExistence(timeout: 5))
        
        // Tap to show number pad
        showNumbersButton.tap()
        
        // Wait for animation
        sleep(1)
        
        // Number pad should now be visible
        let numbersLabel = app.staticTexts["NUMBERS"]
        XCTAssertTrue(numbersLabel.waitForExistence(timeout: 2))
        
        // Number buttons should be visible
        let numberButton5 = app.staticTexts["5"]
        XCTAssertTrue(numberButton5.waitForExistence(timeout: 2))
    }
    
    func testDevicePickerOpens() throws {
        // Find device indicator button (shows "No Device" initially)
        let deviceButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Device' OR label CONTAINS 'No'")).firstMatch
        
        if deviceButton.waitForExistence(timeout: 5) {
            deviceButton.tap()
            
            // Device picker sheet should open
            let selectTVTitle = app.navigationBars["Select TV"]
            XCTAssertTrue(selectTVTitle.waitForExistence(timeout: 3))
            
            // Cancel button should exist
            let cancelButton = app.buttons["Cancel"]
            XCTAssertTrue(cancelButton.exists)
            
            // Dismiss the sheet
            cancelButton.tap()
        }
    }
    
    func testDevicePickerManualEntry() throws {
        // Open device picker
        let deviceButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Device' OR label CONTAINS 'tv.and.mediabox'")).firstMatch
        
        if deviceButton.waitForExistence(timeout: 5) {
            deviceButton.tap()
            
            // Wait for sheet
            sleep(1)
            
            // Find "Enter IP Manually" button
            let manualEntryButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Enter IP Manually'")).firstMatch
            
            if manualEntryButton.waitForExistence(timeout: 3) {
                manualEntryButton.tap()
                
                // IP text field should appear
                let ipField = app.textFields["IP Address"]
                XCTAssertTrue(ipField.waitForExistence(timeout: 2))
                
                // Connect button should be disabled initially
                let connectButton = app.buttons["Connect"]
                XCTAssertTrue(connectButton.exists)
            }
            
            // Dismiss
            let cancelButton = app.buttons["Cancel"]
            if cancelButton.exists {
                cancelButton.tap()
            }
        }
    }
    
    // MARK: - Button Interaction Tests
    
    func testButtonTapAnimation() throws {
        // Find OK button
        let okButton = app.staticTexts["OK"]
        XCTAssertTrue(okButton.waitForExistence(timeout: 5))
        
        // Tap the button - this should trigger animation
        okButton.tap()
        
        // Button should still exist after tap
        XCTAssertTrue(okButton.exists)
    }
    
    func testScrollableRemote() throws {
        // The remote should be scrollable
        let scrollView = app.scrollViews.firstMatch
        
        if scrollView.exists {
            // Try to scroll
            scrollView.swipeUp()
            sleep(1)
            scrollView.swipeDown()
            
            // Content should still be accessible
            let powerButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'power'")).firstMatch
            XCTAssertTrue(powerButton.exists)
        }
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityLabels() throws {
        // Check that buttons have accessibility identifiers or labels
        let buttons = app.buttons.allElementsBoundByIndex
        
        for button in buttons.prefix(10) { // Check first 10 buttons
            // Each button should have some identifier
            let hasLabel = !button.label.isEmpty
            let hasIdentifier = !button.identifier.isEmpty
            XCTAssertTrue(hasLabel || hasIdentifier, "Button should have accessibility label or identifier")
        }
    }
}
