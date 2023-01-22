import Foundation
import Alamofire

/// Combines given request loaders into a single one. The resulting request loader will load a given request using the
/// first request loader which can respond that specific request. First loader in the list has the highest precedence.
///
/// If none of the request loaders can respond to a given request, `UnableToLoadRequestError` is returned as the result,
/// with an empty body.
///
/// - Parameter loaders: Request loaders to use.
/// - Returns: Resulting request loader.
public func combineRequestLoaders(_ loaders: HTTPRequestLoader...) -> HTTPRequestLoader {
    CompositeRequestLoader(loaders: loaders)
}

/// Thrown when a request loader chain cannot load a specific request.
public struct UnableToLoadRequestError: Error {
    public let request: Request
}

private final class CompositeRequestLoader: HTTPRequestLoader {
    
    private let loaders: [HTTPRequestLoader]
    
    init(loaders: [HTTPRequestLoader]) {
        self.loaders = loaders
    }
    
    func canRespond(to request: DataRequest) -> Bool {
        return true // at least one of the loaders in a loader chain should handle the request.
    }
    
    func load(_ request: DataRequest) async -> DataResponse<Data, Error> {
        guard let loader = loaders.first(where: { $0.canRespond(to: request) }) else {
            return DataResponse<Data, Error>(
                request: request.convertible.urlRequest,
                response: nil,
                data: nil,
                metrics: nil,
                serializationDuration: 0,
                result: .failure(UnableToLoadRequestError(request: request))
            )
        }
        return await loader.load(request)
    }
}
