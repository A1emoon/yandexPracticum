import UIKit

final class MovieQuizViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    //MARK: - Private Properties
    private var answeredQuestionCount = 0
    private var correctAnswers = 0
    
    private let questionAmount: Int = 10
    lazy private var questionFactory: QuestionFactoryProtocol = QuestionFactory(delegate: self)
    private var currentQuestion: QuizQuestion?
    
    private let alertPresenter = AlertPresenter()
    
    private let statisticService: StatisticServiceProtocol = StatisticService()
    
    // MARK: - Types
    private enum Constants {
        static let imageBorderWidth: CGFloat = 8
        static let answerHighlightDuration: TimeInterval = 1
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(NSHomeDirectory())
        configureUI()
        
        restartGame()
    }
    
    // MARK: - IBActions
    @IBAction private func noButtonClicked() {
        didAnswer(false)
    }
    
    @IBAction private func yesButtonClicked() {
        didAnswer(true)
    }
    
    // MARK: - Private Methods
    private func didAnswer(_ answer: Bool) {
        guard let currentQuestion else { return }
        
        setButtonsEnabled(false)
        
        answeredQuestionCount += 1
        
        let isCorrect = answer == currentQuestion.correctAnswer
        if isCorrect {
            correctAnswers += 1
        }
        showAnswerResults(isCorrect: isCorrect)
    }
    
    private func configureUI() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = Constants.imageBorderWidth
        imageView.layer.borderColor = nil
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(named: model.imageName) ?? UIImage(),
            question: model.text,
            questionNumber: "\(answeredQuestionCount + 1)/\(questionAmount)"
        )
    }
    
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
        imageView.layer.borderColor = UIColor.clear.cgColor
        setButtonsEnabled(true)
    }
    
    private func showAnswerResults(isCorrect: Bool) {
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.answerHighlightDuration) { [weak self] in
            guard let self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if answeredQuestionCount == questionAmount {
            let currentGame = GameResult(
                correct: correctAnswers,
                total: questionAmount,
                date: Date()
            )
            statisticService.store(currentGame)
            
            let endGameAlert = AlertModel(
                title:  "Этот раунд окончен!",
                message: """
                    Ваш результат: \(correctAnswers)/\(questionAmount)
                    Количество сыгранных квизов: \(statisticService.gamesCount)
                    Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(Date().dateTimeString))
                    Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                    """,
                buttonText: "Сыграть еще раз"
            ) { [weak self] in
                self?.restartGame()
            }
            
            alertPresenter.show(in: self, model: endGameAlert)
        } else {
            questionFactory.requestNextQuestion()
            
            guard let newQuestion = currentQuestion else { return }
            let newModel = convert(model: newQuestion)
            
            DispatchQueue.main.async { [weak self] in
                self?.show(quiz: newModel)
            }
        }
    }
    
    private func setButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    private func restartGame() {
        correctAnswers = 0
        answeredQuestionCount = 0
        
        showNextQuestionOrResults()
    }
}

// MARK: - Extensions
extension MovieQuizViewController: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        
        currentQuestion = question
    }
}
