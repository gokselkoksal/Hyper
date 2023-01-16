import Foundation
import Alamofire

public final class RequestLoaderChain: HTTPRequestLoader {
    
    public enum Error: Swift.Error {
        case unableToLoadRequest(Request)
    }
    
    private let loaders: [HTTPRequestLoader] = []
    
    public func canLoad(_ request: DataRequest) -> Bool {
        return true // at least one of the loaders in a loader chain should handle the request.
    }
    
    public func load(_ request: DataRequest) async -> HTTPDataResponse<Data> {
        guard let loader = loaders.first(where: { $0.canLoad(request) }) else {
            return HTTPDataResponse<Data>(
                request: nil,
                response: nil,
                data: nil,
                metrics: nil,
                serializationDuration: 0,
                result: .failure(Error.unableToLoadRequest(request))
            )
        }
        return await loader.load(request)
    }
}
