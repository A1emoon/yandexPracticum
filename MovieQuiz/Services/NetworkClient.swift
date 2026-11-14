import Foundation

struct NetworkClient {

    private enum NetworkError: Error {
        case httpStatusCode(Int)
        case invalidResponse
        case missingData
    }
    
    func fetch(url: URL, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                completionHandler(.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200..<300:
                    guard let data else {
                        completionHandler(.failure(NetworkError.missingData))
                        return
                    }
                    completionHandler(.success(data))
                    
                default:
                    completionHandler(.failure(NetworkError.httpStatusCode(response.statusCode)))
                    return
                }
            } else {
                completionHandler(.failure(NetworkError.invalidResponse))
                return
            }
        }
        
        task.resume()
    }
}
