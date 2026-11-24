import Testing
@testable import MovieQuiz
import Foundation

final class MovieQuizControllerMock: MovieQuizViewControllerProtocol {
    var viewModel: QuizStepViewModel?
    
    func show(quiz step: MovieQuiz.QuizStepViewModel) {
        viewModel = step
    }
    func showAnswerResults(isCorrect: Bool) { }
    func setButtonsEnabled(_ isEnabled: Bool) { }
    func setLoadingVisible(_ isHidden: Bool) { }
    func showAlert(alertModel: MovieQuiz.AlertModel) { }
}

struct MovieQuizPresenterTests {

    @Test func correctConvertModel() throws {
        let viewControllerMock = MovieQuizControllerMock()
        let presenter = MovieQuizPresenter(view: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(
            imageData: Data(),
            text: "text",
            correctAnswer: true
        )
        presenter.didReceiveNextQuestion(question: question)
        
        #expect(viewControllerMock.viewModel?.imageData == emptyData)
        #expect(viewControllerMock.viewModel?.question == "text")
        #expect(viewControllerMock.viewModel?.questionNumber == "1/10")
        
    }

}
