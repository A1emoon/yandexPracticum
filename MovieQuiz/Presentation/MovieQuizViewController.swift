import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showAnswerResults(isCorrect: Bool)
    func setButtonsEnabled(_ isEnabled: Bool)
    func setLoadingVisible(_ isHidden: Bool)
    func showAlert(alertModel: AlertModel)
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    //MARK: - IBOutlets
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Private Properties
    private let alertPresenter = AlertPresenter()
    private lazy var presenter: MovieQuizPresenterProtocol = MovieQuizPresenter(view: self)
    
    // MARK: - Types
    private enum Constants {
        static let imageBorderWidth: CGFloat = 8
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        presenter.onViewDidLoad()
    }
    
    // MARK: - IBActions
    @IBAction private func noButtonClicked() {
        presenter.didAnswer(false)
    }
    
    @IBAction private func yesButtonClicked() {
        presenter.didAnswer(true)
    }
    
    // MARK: - Private Methods
    private func configureUI() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = Constants.imageBorderWidth
        imageView.layer.borderColor = nil
    }
    
    // MARK: - Public Methods
    func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = UIImage(data: step.imageData)
        textLabel.text = step.question
        imageView.layer.borderColor = UIColor.clear.cgColor
        setButtonsEnabled(true)
    }
    
    func showAnswerResults(isCorrect: Bool) {
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func setButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    func setLoadingVisible(_ isVisible: Bool) {
        activityIndicator.isHidden = !isVisible
        if isVisible {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func showAlert(alertModel: AlertModel) {
        alertPresenter.show(in: self, model: alertModel)
    }
    
}

