//
//  ViewController.swift
//  Counter
//
//  Created by Александр Шляхов on 21.09.2026.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var historyView: UIView!
    @IBOutlet weak var counterValueLabel: UILabel!
    @IBOutlet weak var historyTextView: UITextView!
    
    
    private var counter: Int = 0
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "[dd.MM.yyyy, HH:mm]: "
        return formatter
    }()
    
    
    private enum EventType {
        case plus
        case minus
        case reset
        case invalidDecrement
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        counterValueLabel.backgroundColor = .systemBackground
        counterValueLabel.layer.cornerRadius = 18
        counterValueLabel.clipsToBounds = true
        
        historyView.backgroundColor = .systemBackground
        historyView.layer.cornerRadius = 18
        historyView.clipsToBounds = true
        
        historyTextView.backgroundColor = .clear
        
        updateCounterLabel()
    }
    

    @IBAction func plusButton(_ sender: Any) {
        counter += 1
        updateCounterLabel()
        
        updateHistory(event: .plus)
    }
    
    @IBAction func minusButton(_ sender: Any) {
        if counter == 0 {
            updateHistory(event: .invalidDecrement)
            return
        }
        
        counter -= 1
        updateCounterLabel()
        
        updateHistory(event: .minus)
    }
    
    @IBAction func resetButton(_ sender: Any) {
        counter = 0
        updateCounterLabel()
        
        updateHistory(event: .reset)
    }
    
    @IBAction func clearHistoryButton(_ sender: Any) {
        historyTextView.text = ""
    }
    
    
    private func updateCounterLabel() {
        counterValueLabel.text = String(counter)
    }
    
    private func updateHistory(event: EventType) {
        let date = formatter.string(from: Date())
        
        switch event {
        case .plus:
            historyTextView.text += "\(date) значение изменено на +1\n"
        case .minus:
            historyTextView.text += "\(date) значение изменено на -1\n"
        case .reset:
            historyTextView.text += "\(date) значение сброшено\n"
        case .invalidDecrement:
            historyTextView.text += "\(date) попытка уменьшить значение счётчика ниже 0\n"
        }
    }
}

