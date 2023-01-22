import Foundation
import Alamofire

/// A request loader which returns stubbed responses. This loader only responds to requests if it has a stub for the
/// given request.
public final class StubbedRequestLoader: HTTPRequestLoader {
    
    /// Thrown when stubbing is not enabled but `load` is called anyway.
    public struct NotEnabledError: LocalizedError {
        public var errorDescription: String? {
            "Stubbing is not enabled."
        }
    }
    
    public struct Options {
        
        /// True if stub provider is enabled.
        public var isEnabled: Bool
        
        /// Artificial delay to apply before responding to a request. Defaults to nil, which results in no delay.
        public var responseDelay: TimeInterval?
        
        public init(isEnabled: Bool = true, responseDelay: TimeInterval? = nil) {
            self.isEnabled = isEnabled
            self.responseDelay = responseDelay
        }
    }
    
    public let provider: HTTPStubProvider
    public var options: Options
    
    public init(provider: HTTPStubProvider, options: Options = Options()) {
        self.provider = provider
        self.options = options
    }
    
    public func canRespond(to request: DataRequest) -> Bool {
        guard options.isEnabled, let urlRequest = request.convertible.urlRequest else { return false }
        return provider.hasStub(for: urlRequest)
    }
    
    public func load(_ request: DataRequest) async -> DataResponse<Data, Error> {
        guard options.isEnabled else {
            return DataResponse.failure(request: nil, error: NotEnabledError())
        }
        if let responseDelay = options.responseDelay {
            do {
                try await Task.sleep(seconds: responseDelay)
            } catch {
                return DataResponse.failure(request: nil, error: error)
            }
        }
        let urlRequest: URLRequest
        do {
            urlRequest = try request.convertible.asURLRequest()
        } catch {
            return DataResponse.failure(request: nil, error: error)
        }
        let stub: HTTPResponseStub
        do {
            stub = try await provider.stub(for: urlRequest)
        } catch {
            return DataResponse.failure(request: urlRequest, error: error)
        }
        return DataResponse.stub(request: urlRequest, response: stub)
    }
}

private extension DataResponse {
    
    static func failure(
        request: URLRequest?,
        statusCode: Int = 404,
        error: Failure
    ) -> Self {
        DataResponse(
            request: request,
            response: request?.url.flatMap {
                HTTPURLResponse(url: $0, statusCode: statusCode, httpVersion: nil, headerFields: nil)
            },
            data: nil,
            metrics: nil,
            serializationDuration: 0,
            result: Result.failure(error)
        )
    }
}

private extension DataResponse where Success == Data, Failure == Error {
    
    static func stub(
        request: URLRequest,
        response: HTTPResponseStub
    ) -> Self {
        DataResponse(
            request: request,
            response: request.url.flatMap {
                HTTPURLResponse(
                    url: $0,
                    statusCode: response.statusCode,
                    httpVersion: nil,
                    headerFields: response.headers?.dictionary
                )
            },
            data: response.data,
            metrics: nil,
            serializationDuration: 0,
            result: response.result
        )
    }
}

private extension Task where Success == Never, Failure == Never {
    
    static func sleep(seconds: TimeInterval) async throws {
        let nanoseconds = seconds * TimeInterval(NSEC_PER_SEC)
        try await Self.sleep(nanoseconds: UInt64(nanoseconds))
    }
}
