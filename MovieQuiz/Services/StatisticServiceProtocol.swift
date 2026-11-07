protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalCorrectAnswers: Int { get }
    var totalQuestionsAsked: Int { get }
    var totalAccuracy: Double { get }
    
    func store(_ result: GameResult)
}
