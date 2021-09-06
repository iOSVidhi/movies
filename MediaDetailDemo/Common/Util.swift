

import Foundation
import  UIKit
import SystemConfiguration

class Util: NSObject {
    
    private override init() {}

    // shared instance of Util.
    static let sharedInstance: Util = Util()
    
    // to check string is null or not.
    class func isStringNull(srcString: String) -> Bool {
        
        if srcString != "" && srcString !=  "null" && !(srcString == "<null>") && !(srcString == "(null)") && (srcString.count) > 0{
            return false
        }
        return true
    }
    
    // to check is internet connectivity is available or not.
    class func isInternetAvailable() -> Bool {

       var zeroAddress = sockaddr_in()
       zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
       zeroAddress.sin_family = sa_family_t(AF_INET)
       
       let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
           $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
               SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
           }
       }
       
       var flags = SCNetworkReachabilityFlags()
       if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
           return false
       }
       let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
       let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
       return (isReachable && !needsConnection)
    }
    
    // to get Image from URL
    class func getImageFromUrl(strUrl: String, completion: @escaping(_ image: UIImage) -> ()){
        if let url = URL(string: strUrl){
            if let data = try? Data(contentsOf: url){
                completion(UIImage(data: data)!)
            } else {
                completion(UIImage())
            }
        } else {
            completion(UIImage())
        }
    }
    
   
    // to print log in to console.
    class func printLog( _ details : Any = "", _ title : String = "") {
        print("\(title) : \(details)")
    }
}
