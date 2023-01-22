import Foundation
import Alamofire

public protocol HTTPRequestLoader {
    
    /// Returns true if the request loader can respond to a specific request.
    /// - Parameter request: Request to respond to.
    func canRespond(to request: DataRequest) -> Bool
    
    
    /// Loads the given request and returns a data response.
    /// - Parameter request: Request to load.
    func load(_ request: DataRequest) async -> DataResponse<Data, Error>
}

public extension HTTPRequestLoader {

    func canRespond(to request: DataRequest) -> Bool {
        return true
    }
}
