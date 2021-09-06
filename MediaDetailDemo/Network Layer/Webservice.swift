import Foundation
import Alamofire

enum WebError: Error {
    
    /// Throws when server don't give any response
    case noData
    
    /// Throws when internet isn't connected
    case noInternet
    
    /// Throws when server is down because of any reason
    case hostFail
    
    /// Throws when response is not as per predefined json format
    case parseFail
    
    /// Throws when request timeout occurs
    case timeout
    
    /// Throws when server unauthorise user
    case unAuthorise
    
    /// Throws when application cancel running request
    case cancel
    
    /// Throws when error is none of the above
    case unknown
    
    static func getErrorByCode(_ statusCode: Int!) -> WebError {
        switch statusCode {
        case 400:
            return .noData
        case 401:
            return .unAuthorise
            
        case 404:
            return .noData
        case 500:
            return .hostFail
        default:
            return .unknown
        }
    }
    
    var errorMessage: String {
        switch self {
        case .noData:
            return "No data found."
        case .noInternet:
            return "Network not reachable."
        case .hostFail:
            return "Failed to retrieve host."
        case .parseFail:
            return "Failed to parse data."
        case .timeout:
            return "Request timed out."
        case .unAuthorise:
            return "You are not authorised."
        case .cancel:
            return "Canceled request."
        case .unknown:
            return "Coundn't process request at the moment, please try again later."
            
        }
    }    
}

class Webservice: Session {
    
    
    // Custom header field
    var header : HTTPHeaders = [
        "Content-Type":"application/json"
    ]
    
    static let API: Webservice = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 60
        configuration.timeoutIntervalForRequest  = 60
        var webService = Webservice(configuration: configuration)
        return webService
    }()
    
    /// Set Bearer Token here

    func set(authorizeToken token: String?) {
        header[""] = token!
    }
    
    func cancelAllTasks() {
        self.session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
            dataTasks.forEach { $0.cancel() }
            uploadTasks.forEach { $0.cancel() }
            downloadTasks.forEach { $0.cancel() }
        }
    }
    
    func sendRequest<T: Codable>(_ route: Router, type: T.Type,
                                 successCompletion: @escaping (_ response: T) -> Void,
                                 failureCompletion: @escaping (_ failure: WebError, _ detail: ErrorResponse?) -> Void) {
        
        guard Util.isInternetAvailable() == true else {
            failureCompletion(WebError.noInternet, nil)
            return
        }
        
        let path = route.path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        var parameter = route.parameters
        
        if route.parameters == nil || route.parameters?.count == 0 {
            parameter = [:]
        }
        
        var encoding: ParameterEncoding = JSONEncoding.default
        if route.method == .get {
            encoding = URLEncoding.default
        }
        
        request(path!, method: route.method,
                parameters: parameter!,
                encoding: encoding,
                headers: self.header)
            .responseData { (response) in
                if let statusCode = response.response?.statusCode,
                   statusCode != 200 {
                    let error = WebError.getErrorByCode(statusCode)
                    if statusCode != 401,
                       let data = response.data,
                       let errorResp = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                        var customServerError = errorResp
                        customServerError.statusCode = Generic(statusCode)
                        failureCompletion(error, customServerError)
                    } else {
                        failureCompletion(error, nil)
                        print(error)
                    }
                    return
                }
                
                switch response.result {
                case .success(let value):
                    print("Response: \t", String(data: value, encoding: .utf8) ?? "")
                    if let resp = try? JSONDecoder().decode(type.self, from: value) {
                        successCompletion(resp)
                    } else {
                        if let success = SuccessRespose(status: "") as? T {
                            successCompletion(success)
                        } else {
                            failureCompletion(WebError.unknown, nil)
                        }
                    }
                //print(String(data: value, encoding: .utf8)!)
                
                case .failure(let error):
                    print(error)
                    if error._code == NSURLErrorTimedOut {
                        failureCompletion(WebError.timeout, nil)
                    } else if error._code == NSURLErrorCannotConnectToHost {
                        failureCompletion(WebError.hostFail, nil)
                    } else if error._code == NSURLErrorCancelled {
                        failureCompletion(WebError.cancel, nil)
                    } else if error._code == NSURLErrorNetworkConnectionLost {
                        failureCompletion(WebError.unknown, nil)
                    } else if let statusCode = response.response?.statusCode,
                              statusCode == 200 {
                        if let success = SuccessRespose(status: "") as? T {
                            successCompletion(success)
                        } else {
                            failureCompletion(WebError.parseFail, nil)
                        }
                        
                    } else {
                        failureCompletion(WebError.unknown, nil)
                    }
                }
            }
    }
    struct ErrorResponse: Codable {
        let code    : Generic?
        let title   : Generic?
        let detail  : Generic?
        var statusCode : Generic? = nil
        
        enum CodingKeys: String, CodingKey {
            case code = "code"
            case title = "title"
            case detail = "detail"
        }
        
        init(from decoder: Decoder) throws {
            let values  = try decoder.container(keyedBy: CodingKeys.self)
            code   = try values.decodeIfPresent(Generic.self, forKey: .code)
            title  = try values.decodeIfPresent(Generic.self, forKey: .title)
            detail = try values.decodeIfPresent(Generic.self, forKey: .detail)
        }
    }
    
    struct SuccessRespose: Codable {
        
        let success: Generic?
        
        enum CodingKeys: String, CodingKey {
            case status = "status"
        }
        init(status: String) {
            self.success = Generic(status)
        }
        init(from decoder: Decoder) throws {
            let values  = try decoder.container(keyedBy: CodingKeys.self)
            success   = try values.decodeIfPresent(Generic.self, forKey: .status)
        }
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy : CodingKeys.self)
            try container.encode(success, forKey: .status)
        }
    }
}

