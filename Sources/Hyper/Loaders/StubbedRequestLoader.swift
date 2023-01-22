import Foundation
import Alamofire

/// A request loader which returns stubbed responses. This loader only responds to requests if it has a stub for the
/// given request.
public final class StubbedRequestLoader: HTTPRequestLoader {
    
    public let provider: HTTPStubProvider
    
    public init(provider: HTTPStubProvider) {
        self.provider = provider
    }
    
    public func canRespond(to request: DataRequest) -> Bool {
        guard let urlRequest = request.convertible.urlRequest else { return false }
        return provider.hasStub(for: urlRequest)
    }
    
    public func load(_ request: DataRequest) async -> DataResponse<Data, Error> {
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

extension DataResponse {
    
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

extension DataResponse where Success == Data, Failure == Error {
    
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
