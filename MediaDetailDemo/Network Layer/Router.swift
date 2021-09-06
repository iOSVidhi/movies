import Foundation
import Alamofire


protocol Routable {
    var path        : String { get }
    var method      : HTTPMethod { get }
    var parameters  : Parameters? { get }
}

enum Router: Routable {
    case moviesList(pageNumber : String)
}

extension Router {
    var path: String {
        var endApiPath = ""
        switch self {
        case .moviesList(let pageNumber) :
            endApiPath = "https://api.themoviedb.org/3/discover/movie?api_key=\(APIKEY)&page=\(pageNumber)"
        }
        return  endApiPath
    }
}

extension Router {
    var method: HTTPMethod {
        switch  self {

        default:
            return .get
        }
    }
}

extension Router {
    var parameters: Parameters? {
        switch self {
    
        case .moviesList :
            return nil
        }
    }
}
