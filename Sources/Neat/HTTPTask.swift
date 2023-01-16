import Foundation
import Alamofire

public typealias HTTPDataResponse<T> = DataResponse<T, Error>
public typealias HTTPDataTask<Value> = HTTPTask<DataRequest, Value>

public struct HTTPTask<Request: Alamofire.Request, Value> {

    public let request: Request
    
    public var response: HTTPDataResponse<Value> {
        get async {
            await perform()
        }
    }
    
    public var result: Result<Value, Error> {
        get async {
            await response.result
        }
    }

    public var value: Value {
        get async throws {
            try await result.get()
        }
    }

    private let perform: () async -> HTTPDataResponse<Value>

    public init(request: Request, perform: @escaping () async -> HTTPDataResponse<Value>) {
        self.request = request
        self.perform = perform
    }
}

// MARK: - Convenience

public extension HTTPTask {
    
    func map<NewValue>(_ transform: @escaping (HTTPDataResponse<Value>) -> HTTPDataResponse<NewValue>) -> HTTPTask<Request, NewValue> {
        HTTPTask<Request, NewValue>(request: request) {
            transform(await response)
        }
    }
    
    func mapValue<NewValue>(_ transform: @escaping (Value) -> NewValue) -> HTTPTask<Request, NewValue> {
        HTTPTask<Request, NewValue>(request: request) {
            await perform().map(transform)
        }
    }

    func decoding<NewValue>(with transform: Transform<HTTPDataResponse<Value>, HTTPDataResponse<NewValue>>) -> HTTPTask<Request, NewValue> {
        HTTPTask<Request, NewValue>(request: request) {
            let response = await perform()
            do {
                return try transform.apply(response)
            } catch {
                return HTTPDataResponse<NewValue>(
                    request: response.request,
                    response: response.response,
                    data: response.data,
                    metrics: response.metrics,
                    serializationDuration: response.serializationDuration,
                    result: .failure(error)
                )
            }
        }
    }

    func decodingValue<NewValue>(with transform: Transform<Value, NewValue>) -> HTTPTask<Request, NewValue> {
        HTTPTask<Request, NewValue>(request: request) {
            await perform().tryMap(transform.apply)
        }
    }
}

public extension HTTPTask where Value == Data {
    
    func decodingValue<T: Decodable>(as type: T.Type = T.self, decoder: JSONDecoder = JSONDecoder()) -> HTTPTask<Request, T> {
        decodingValue(with: .decodableTransform(using: decoder))
    }
}

public extension HTTPTask where Request == DataRequest {
    
    var underlyingURLRequest: URLRequest? {
        request.convertible.urlRequest
    }
}
