import Foundation

extension Array<MostPopularMovie> {
    subscript(safe index: Index) -> Element? {
        indices ~= index ? self[index] : nil
    }
}
