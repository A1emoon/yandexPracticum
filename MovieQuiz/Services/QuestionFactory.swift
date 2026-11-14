import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private(set) weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    private var currentMovies: [MostPopularMovie] = []
    
    private enum ComparisonDirection: String, CaseIterable {
        case greaterThan = "больше"
        case lessThan = "меньше"
    }
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate? = nil) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    //MARK: - Public Methods
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self, !movies.isEmpty else { return }
            
            if currentMovies.isEmpty {
                currentMovies = movies
            }
            
            let index = (0..<self.currentMovies.count).randomElement() ?? 0
            
            let movie = self.currentMovies.remove(at: index)
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image: \(error)")
            }
            
            let randomRating = Float.random(in: 8...10)
            let formattedRating = String(format: "%.1f", randomRating)
            let comparisonDirection = ComparisonDirection.allCases.randomElement() ?? ComparisonDirection.greaterThan
            let text = "Рейтинг этого фильма \(comparisonDirection.rawValue) чем \(formattedRating)?"
            
            var correctAnswer: Bool {
                switch comparisonDirection{
                case .greaterThan:
                    return movie.rating > randomRating
                case .lessThan:
                    return movie.rating < randomRating
                }
            }
            
            let question = QuizQuestion(
                imageData: imageData,
                text: text,
                correctAnswer: correctAnswer
            )
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
