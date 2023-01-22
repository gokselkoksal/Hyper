import Foundation
import Alamofire

public protocol APIClient {
    var session: Alamofire.Session { get }
    var loader: HTTPRequestLoader { get }
    var baseURL: () -> URL { get }
    var defaultHeaders: () -> HTTPHeaders { get }
}

public extension APIClient {
    
    /// Returns a request URL relative to the base URL.
    /// - Parameter path: URL path for a specific request.
    func requestURL(with path: URL.Path) -> URL {
        URL(baseURL: baseURL(), path: path.rawValue)
    }
    
    /// Combines given headers with default headers and returns the final result.
    /// - Parameter headers: Headers for a specific request. Takes precedence over default headers.
    func requestHeaders(with headers: HTTPHeaders?) -> HTTPHeaders {
        var mergedHeaders = defaultHeaders()
        headers?.forEach({ mergedHeaders.add($0) })
        return mergedHeaders
    }
    
    func task(
        request: DataRequest
    ) -> HTTPTask<Data> {
        return HTTPTask(request: request) {
            await loader.load(request)
        }
    }
    
    func task(
        urlRequest: URLRequest,
        interceptor: RequestInterceptor? = nil
    ) -> HTTPTask<Data> {
        let request = session.request(urlRequest, interceptor: interceptor)
        return task(request: request)
    }
    
    func task(
        path: URL.Path,
        method: HTTPMethod,
        parameters: HTTPRequestParameters? = nil,
        headers: HTTPHeaders? = nil,
        interceptor: RequestInterceptor? = nil,
        requestModifier: Session.RequestModifier? = nil
    ) -> HTTPTask<Data> {
        let request = session.request(
            requestURL(with: path),
            method: method,
            parameters: parameters?.values.compactMapValues({ $0 }),
            encoding: parameters?.encoding ?? URLEncoding.default,
            headers: requestHeaders(with: headers),
            interceptor: interceptor,
            requestModifier: requestModifier
        )
        return task(request: request)
    }
}
