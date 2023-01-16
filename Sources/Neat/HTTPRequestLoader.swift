import Foundation
import Alamofire

public protocol HTTPRequestLoader {
    func canLoad(_ request: DataRequest) -> Bool
    func load(_ request: DataRequest) async -> HTTPDataResponse<Data>
}

public extension HTTPRequestLoader {
    
    func canLoad(_ request: DataRequest) -> Bool {
        return true
    }
}
