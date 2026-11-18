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
    
    private enum APIError: Error {
        case errorMessage(String)
    }
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate? = nil) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    //MARK: - Public Methods
    func loadData() {
        moviesLoader.loadMovies { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let mostPopularMovies):
                    if let errorMessage = mostPopularMovies.errorMessage {
                        self.delegate?.didFailToLoadData(with: APIError.errorMessage(errorMessage))
                        return
                    }
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async {
            guard !self.movies.isEmpty else { return }
            
            if self.currentMovies.isEmpty {
                self.currentMovies = self.movies
            }
            
            let index = (0..<self.currentMovies.count).randomElement() ?? 0
            
            let movie = self.currentMovies.remove(at: index)
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                self.delegate?.didFailToLoadImage()
                return
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
            
            DispatchQueue.main.async {
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
