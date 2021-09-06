
import Foundation

enum Server {
    case developement
}

class Environment {
    static let server : Server = .developement
    
    static let localURL = ""
    
    class func APIBasePath() -> String {
        switch self.server {
        case .developement:
            return localURL
        }
    }
}
