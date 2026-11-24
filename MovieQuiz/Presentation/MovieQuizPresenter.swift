import Foundation

protocol MovieQuizPresenterProtocol {
    func onViewDidLoad()
    func didAnswer(_ answer: Bool)
}

final class MovieQuizPresenter: MovieQuizPresenterProtocol {
    // MARK: - Private Properties
    weak private var view: MovieQuizViewControllerProtocol?
    private let questionsAmount: Int = 10
    private var answeredQuestionCount = 0
    private var correctAnswers = 0
    
    lazy private var questionFactory: QuestionFactoryProtocol = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
    private var currentQuestion: QuizQuestion?
    
    private let statisticService: StatisticServiceProtocol = StatisticService()
    
    // MARK: - Types
    private enum Constants {
        static let answerHighlightDuration: TimeInterval = 1
    }
    
    // MARK: - Init
    init(view: MovieQuizViewControllerProtocol) {
        self.view = view
    }
    
    // MARK: - Private Methods
    private func restartGame() {
        correctAnswers = 0
        answeredQuestionCount = 0
        proceedToNextStep()
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            imageData: model.imageData,
            question: model.text,
            questionNumber: "\(answeredQuestionCount + 1)/\(questionsAmount)"
        )
    }
    
    private func proceedToNextStep() {
        if answeredQuestionCount == questionsAmount {
            finishGame()
        } else {
            questionFactory.requestNextQuestion()
        }
    }
    
    private func finishGame() {
        let currentGame = GameResult(
            correct: correctAnswers,
            total: questionsAmount,
            date: Date()
        )
        statisticService.store(currentGame)
        
        let endGameAlert = AlertModel(
            title:  String(localized: "round.finished.title"),
            message: """
                Ваш результат: \(correctAnswers)/\(questionsAmount)
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                """,
            buttonText: String(localized: "round.finished.buttonText")
        ) { [weak self] in
            self?.restartGame()
        }
        
        view?.showAlert(alertModel: endGameAlert)
    }
    
    // MARK: - Public Methods
    func onViewDidLoad() {
        view?.setButtonsEnabled(false)
        view?.setLoadingVisible(true)
        questionFactory.loadData()
    }
    
    func didAnswer(_ answer: Bool) {
        guard let currentQuestion else { return }
        
        view?.setButtonsEnabled(false)
        
        answeredQuestionCount += 1
        
        let isCorrect = answer == currentQuestion.correctAnswer
        if isCorrect {
            correctAnswers += 1
        }
        
        view?.showAnswerResults(isCorrect: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.answerHighlightDuration) {
            self.proceedToNextStep()
        }
    }
}

// MARK: - Extensions
extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        view?.show(quiz: viewModel)
    }
    
    func didLoadDataFromServer() {
        view?.setLoadingVisible(false)
        questionFactory.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let alertModel = AlertModel(
            title: String(localized: "error.network.title"),
            message: error.localizedDescription,
            buttonText: String(localized: "error.network.buttonText")) { [weak self] in
                self?.correctAnswers = 0
                self?.answeredQuestionCount = 0
                self?.questionFactory.loadData()
            }
        
        view?.showAlert(alertModel: alertModel)
    }
    
    func didFailToLoadImage() {
        let alertModel = AlertModel(
            title: String(localized: "error.network.title"),
            message: String(localized: "error.network.loadImage"),
            buttonText: String(localized: "error.network.loadImage.buttonText")) { [weak self] in
                self?.questionFactory.requestNextQuestion()
            }
        
        view?.showAlert(alertModel: alertModel)
    }
}
