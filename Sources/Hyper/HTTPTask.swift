import Foundation
import Alamofire

public struct HTTPTask<Value> {

    public let request: DataRequest
    
    public var response: DataResponse<Value, Error> {
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
    
    public var underlyingURLRequest: URLRequest? {
        request.convertible.urlRequest
    }

    private let perform: () async -> DataResponse<Value, Error>

    public init(request: DataRequest, perform: @escaping () async -> DataResponse<Value, Error>) {
        self.request = request
        self.perform = perform
    }
}

// MARK: - Convenience

public extension HTTPTask {
    
    func map<NewValue>(_ transform: @escaping (DataResponse<Value, Error>) -> DataResponse<NewValue, Error>) -> HTTPTask<NewValue> {
        HTTPTask<NewValue>(request: request) {
            transform(await response)
        }
    }
    
    func mapValue<NewValue>(_ transform: @escaping (Value) -> NewValue) -> HTTPTask<NewValue> {
        HTTPTask<NewValue>(request: request) {
            await perform().map(transform)
        }
    }

    func decoding<NewValue>(with transform: Transform<DataResponse<Value, Error>, DataResponse<NewValue, Error>>) -> HTTPTask<NewValue> {
        HTTPTask<NewValue>(request: request) {
            let response = await perform()
            do {
                return try transform.apply(response)
            } catch {
                return DataResponse<NewValue, Error>(
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

    func decodingValue<NewValue>(with transform: Transform<Value, NewValue>) -> HTTPTask<NewValue> {
        HTTPTask<NewValue>(request: request) {
            await perform().tryMap(transform.apply)
        }
    }
}

public extension HTTPTask where Value == Data {
    
    func decodingValue<T: Decodable>(as type: T.Type = T.self, decoder: JSONDecoder = JSONDecoder()) -> HTTPTask<T> {
        decodingValue(with: .decodableTransform(using: decoder))
    }
}
