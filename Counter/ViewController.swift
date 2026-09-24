import UIKit

final class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var historyView: UIView!
    @IBOutlet private weak var counterValueLabel: UILabel!
    @IBOutlet private weak var historyTextView: UITextView!
    
    
    // MARK: - Properties
    private var counter: Int = 0
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "[dd.MM.yyyy, HH:mm]: "
        return formatter
    }()
    
    
    // MARK: - Types
    private enum EventType {
        case plus
        case minus
        case reset
        case invalidDecrement
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        updateCounterLabel()
    }
    
    
    // MARK: - Private Methods
    private func updateCounterLabel() {
        counterValueLabel.text = String(counter)
    }
    
    private func updateHistory(event: EventType) {
        let message: String
        
        switch event {
        case .plus:
            message = "значение изменено на +1\n"
        case .minus:
            message = "значение изменено на -1\n"
        case .reset:
            message = "значение сброшено\n"
        case .invalidDecrement:
            message = "попытка уменьшить значение счётчика ниже 0\n"
        }
        
        let date = formatter.string(from: Date())
        historyTextView.text += "\(date)\(message)"
        scrollHistoryToBottom()
        
    }
    
    private func configureUI() {
        counterValueLabel.backgroundColor = .systemBackground
        counterValueLabel.layer.cornerRadius = 18
        counterValueLabel.clipsToBounds = true
        
        historyView.backgroundColor = .systemBackground
        historyView.layer.cornerRadius = 18
        historyView.clipsToBounds = true
        
        historyTextView.backgroundColor = .clear
    }
    
    private func scrollHistoryToBottom() {
        let range = NSRange(
            location: historyTextView.text.count - 1,
            length: 1
        )
        historyTextView.scrollRangeToVisible(range)
    }
    
    
    // MARK: - IBAction
    @IBAction private func didTapPlusButton() {
        counter += 1
        updateCounterLabel()
        
        updateHistory(event: .plus)
    }
    
    @IBAction private func didTapMinusButton() {
        guard counter > 0  else {
            updateHistory(event: .invalidDecrement)
            return
        }
        
        counter -= 1
        updateCounterLabel()
        
        updateHistory(event: .minus)
    }
    
    @IBAction private func didTapResetButton() {
        counter = 0
        updateCounterLabel()
        
        updateHistory(event: .reset)
    }
    
    @IBAction private func didTapClearHistoryButton() {
        historyTextView.text = ""
    }
}

