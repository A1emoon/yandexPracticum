import Testing
@testable import MovieQuiz

final class ArrayTests {
    
    @Test func getValueInRange() async throws {
        //Given
        let array = [1, 2, 3, 4, 5]
        
        //When
        let element: Int? = array[safe: 1]
        
        //Then
        #expect(element != nil)
        #expect(element == 2)
    }
    
    @Test func getValueOutOfRange() async throws {
        //Given
        let array = [1, 2, 3, 4, 5]
        
        //When
        let element: Int? = array[safe: 5]
        
        //Then
        #expect(element == nil)
    }
    
}
