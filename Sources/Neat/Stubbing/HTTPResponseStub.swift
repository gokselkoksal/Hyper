import Foundation
import Alamofire

public struct HTTPResponseStub {
    
    public var headers: HTTPHeaders?
    public let statusCode: Int
    public let data: Data
    public let error: Error?
    
    public var result: Result<Data, Error> {
        if let error = error {
            return Result.failure(error)
        } else {
            return Result.success(data)
        }
    }
    
    public init(headers: HTTPHeaders? = nil, statusCode: Int, data: Data, error: Error? = nil) {
        self.headers = headers
        self.data = data
        self.statusCode = statusCode
        self.error = error
    }
}

public extension HTTPResponseStub {
    
    struct Body {
        
        var value: Data {
            get {
                data()
            }
        }
        
        private let data: () -> Data
        
        init(data: @escaping () -> Data) {
            self.data = data
        }
    }
    
    init(statusCode: Int, body: Body, error: Error?) {
        self.init(statusCode: statusCode, data: body.value, error: error)
    }
    
    static func success(body: Body) -> HTTPResponseStub {
        HTTPResponseStub(statusCode: 200, body: body, error: nil)
    }
    
    struct GenericError: Error {
        public init() { }
    }
    
    static func failure(
        statusCode: Int,
        error: Error = GenericError(),
        body: Body = .empty
    ) -> HTTPResponseStub {
        return HTTPResponseStub(statusCode: statusCode, body: body, error: error)
    }
    
    static func notFound(error: Error = GenericError(), body: Body = .empty) -> HTTPResponseStub {
        return HTTPResponseStub(statusCode: 404, body: body, error: error)
    }
}

public extension HTTPResponseStub.Body {
    
    enum Error: Swift.Error {
        case couldNotFindResource(String)
    }
    
    static var empty: Self {
        Self(data: { Data() })
    }
    
    static func data(_ data: Data) -> Self {
        Self(data: { data })
    }
    
    static func json(_ json: Any) throws -> Self {
        return .data(try JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed))
    }
    
    static func resource(name: String, extension ext: String, bundle: Bundle) throws -> Self {
        guard let url = bundle.url(forResource: name, withExtension: ext) else {
            throw Error.couldNotFindResource(name + "." + ext)
        }
        return .data(try Data(contentsOf: url))
    }
    
    static func encodable<T: Encodable>(_ model: T, encoder: JSONEncoder = JSONEncoder()) throws -> Self {
        return .data(try encoder.encode(model))
    }
}
