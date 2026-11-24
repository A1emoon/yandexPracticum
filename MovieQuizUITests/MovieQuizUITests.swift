import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }
    
    func testYesButton() {
        let indexLabel = app.staticTexts["Index"]
        
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        
        sleep(3)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertEqual(indexLabel.label, "2/10")
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testNoButton() {
        let indexLabel = app.staticTexts["Index"]
        
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        
        sleep(3)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertEqual(indexLabel.label, "2/10")
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testResultsAlert() {
        let yesButton = app.buttons["Yes"]
        let indexLabel = app.staticTexts["Index"]

        XCTAssertTrue(indexLabel.waitForExistence(timeout: 10))

        for questionNumber in 1...10 {
            let currentQuestion = NSPredicate(
                format: "label == %@",
                "\(questionNumber)/10"
            )

            expectation(
                for: currentQuestion,
                evaluatedWith: indexLabel
            )

            waitForExpectations(timeout: 10)

            XCTAssertTrue(yesButton.isEnabled)
            yesButton.tap()
        }

        let alert = app.alerts.firstMatch

        XCTAssertTrue(
            alert.waitForExistence(timeout: 10),
            "Итоговый alert не появился"
        )

        XCTAssertTrue(
            alert.staticTexts["Этот раунд окончен!"].exists
        )

        XCTAssertEqual(
            alert.buttons.firstMatch.label,
            "Сыграть еще раз"
        )
    }

    
    func testRestartGame() {
        sleep(3)
        
        (1...10).forEach { _ in
            app.buttons["Yes"].tap()
            sleep(3)
        }
        
        let alert = app.alerts.firstMatch
        alert.buttons.firstMatch.tap()
        
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
}
