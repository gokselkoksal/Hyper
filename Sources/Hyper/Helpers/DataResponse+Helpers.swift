import Foundation
import Alamofire

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
