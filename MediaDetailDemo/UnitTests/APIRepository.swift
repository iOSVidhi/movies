import Foundation
import UIKit

class APIRepository {
    var session: URLSession!
    func getMovieList(completion: @escaping (MovieDecodable?, Error?) -> Void) {
        guard let url = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=e5e7008cb9d77779decea145bfb3eae0")
           else { fatalError() }
         session.dataTask(with: url) { (data, response, error) in
           guard error == nil else {
             completion(nil, error)
             return
           }
           guard let data = data else { return }
            do {
                let movies = try JSONDecoder().decode(MovieDecodable.self, from: data)
                completion(movies, nil)
            }catch (let e){
                completion(nil,e)
            }
         }.resume()
    }
}

class MockURLSession: URLSession {
    var cachedUrl: URL?
    private let mockTask: MockTask
    init(data: Data?, urlResponse: URLResponse?, error: Error?) {
        mockTask = MockTask(data: data, urlResponse: urlResponse, error: error)
    }
    override func dataTask(with url: URL, completionHandler:      @escaping(Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        self.cachedUrl = url
        mockTask.completionHandler = completionHandler
        return mockTask
    }
}

class MockTask: URLSessionDataTask {
  private let data: Data?
  private let urlResponse: URLResponse?
  private let errorA: Error?

  var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
    
  init(data: Data?, urlResponse: URLResponse?, error: Error?) {
    self.data = data
    self.urlResponse = urlResponse
    self.errorA = error
  }
  override func resume() {
    DispatchQueue.main.async {
        self.completionHandler?(self.data, self.urlResponse, self.errorA)
    }
  }
}
