import Foundation
import Alamofire

public protocol APIClient {
    var session: Alamofire.Session { get }
    var loader: HTTPRequestLoader { get }
    var baseURL: () -> URL { get }
    var defaultHeaders: () -> HTTPHeaders { get }
}

public extension APIClient {
    
    func request(
        path: URL.Path,
        method: HTTPMethod,
        parameters: HTTPRequestParameters? = nil,
        headers: HTTPHeaders? = nil,
        interceptor: RequestInterceptor? = nil,
        requestModifier: Session.RequestModifier? = nil
    ) -> HTTPTask<Data> {
        let url = URL(baseURL: baseURL(), path: path.rawValue)
        var allHeaders = defaultHeaders()
        headers?.forEach({ allHeaders.add($0) })
        let request = session.request(
            url,
            method: method,
            parameters: parameters?.values.compactMapValues({ $0 }),
            encoding: parameters?.encoding ?? URLEncoding.default,
            headers: allHeaders,
            interceptor: interceptor,
            requestModifier: requestModifier
        )
        return HTTPTask<Data>(request: request) { [loader] in
            await loader.load(request)
        }
    }
}
