import UIKit

final class MovieQuizViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    //MARK: - Private Properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private var currentQuestion: QuizQuestion {
        questions[currentQuestionIndex]
    }
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            imageName: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            imageName: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            imageName: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            imageName: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            imageName: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            imageName: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            imageName: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ),
        QuizQuestion(
            imageName: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ),
        QuizQuestion(
            imageName: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ),
        QuizQuestion(
            imageName: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        )
    ]
    
    // MARK: - Types
    private enum Constants {
        static let imageBorderWidth: CGFloat = 8
        static let answerHighlightDuration: TimeInterval = 1
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        show(quiz: convert(model: currentQuestion))
    }
    
    // MARK: - IBActions
    @IBAction private func noButtonClicked() {
        didAnswer(false)
    }
    
    @IBAction private func yesButtonClicked() {
        didAnswer(true)
    }
    
    // MARK: - Private Methods
    private func configureUI() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = Constants.imageBorderWidth
        imageView.layer.borderColor = nil
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(named: model.imageName) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)"
        )
    }
    
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
        imageView.layer.borderColor = UIColor.clear.cgColor
        setButtonEnabled(true)
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: result.buttonText,
            style: .default
        ) { [weak self] _ in
            self?.restartGame()
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
        
        setButtonEnabled(true)
    }
    
    private func showAnswerResults(isCorrect: Bool) {
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        if isCorrect {
            correctAnswers += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.answerHighlightDuration) { [weak self] in
            guard let self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            show(
                quiz: QuizResultsViewModel(
                    title: "Этот раунд окончен!",
                    text: "Ваш результат: \(correctAnswers)/\(questions.count)",
                    buttonText: "Сыграть еще раз"
                )
            )
        } else {
            currentQuestionIndex += 1
            show(quiz: convert(model: currentQuestion))
        }
    }
    
    private func didAnswer(_ answer: Bool) {
        setButtonEnabled(false)
        
        let isCorrect = answer == currentQuestion.correctAnswer
        showAnswerResults(isCorrect: isCorrect)
    }
    
    private func setButtonEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        
        let firstQuestion = currentQuestion
        let viewModel = convert(model: firstQuestion)
        
        show(quiz: viewModel)
    }
}
