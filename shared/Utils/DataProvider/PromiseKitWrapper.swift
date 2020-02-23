import Foundation
import PromiseKit

/// Wrapper arround the network calls
class PromiseKitWrapper {
    func getDataFromAPI(baseUrl url: URL) -> Promise<Data> {
            let urlRequest = URLRequest(url: url)
            
            return Promise { seal in
                executeRequest(request: urlRequest) { data, error in
                    if let error = error {
                        seal.reject(error)
                        return
                    }
                    
                    guard data != nil else {
                        seal.reject(Errors.ServerError)
                        return
                    }
                    
                    seal.fulfill(data!)
                }
            }
        }
        
        private func executeRequest(request: URLRequest, completionHandler: @escaping (Data?, Error?)
            -> Void) {
            URLSession.shared.dataTask(with: request) { data, _, error in
                DispatchQueue.main.async {
                    completionHandler(data, error)
                }
            }.resume()
        }
}
