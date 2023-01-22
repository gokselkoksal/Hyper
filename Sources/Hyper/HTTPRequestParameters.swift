import Foundation
import Alamofire

public struct HTTPRequestParameters {
    
    public let values: [String: Any?]
    public let encoding: ParameterEncoding
    
    public init(values: [String : Any?], encoding: ParameterEncoding) {
        self.values = values
        self.encoding = encoding
    }
}

// MARK: - Convenience

public extension HTTPRequestParameters {
    
    static func jsonEncoded(_ values: [String: Any?], options: JSONSerialization.WritingOptions = []) -> HTTPRequestParameters {
        HTTPRequestParameters(values: values, encoding: JSONEncoding(options: options))
    }
    
    static func urlEncoded(_ values: [String: Any?]) -> HTTPRequestParameters {
        HTTPRequestParameters(values: values, encoding: URLEncoding.default)
    }
}
