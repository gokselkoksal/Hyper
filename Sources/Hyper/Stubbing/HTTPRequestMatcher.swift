import Foundation
import Alamofire

public struct HTTPRequestMatcher: Identifiable, Hashable {
    
    public let id: String
    private let match: (URLRequest) -> Bool
    
    public init(id: String = UUID().uuidString, match: @escaping (_ request: URLRequest) -> Bool) {
        self.id = id
        self.match = match
    }
    
    public func matches(_ request: URLRequest) -> Bool {
        return match(request)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension HTTPRequestMatcher: Equatable {
    public static func == (lhs: HTTPRequestMatcher, rhs: HTTPRequestMatcher) -> Bool {
        return lhs.id == rhs.id
    }
}

public extension HTTPRequestMatcher {
    
    static func combine(_ matchers: HTTPRequestMatcher...) -> HTTPRequestMatcher {
        combine(matchers: matchers)
    }
    
    static func combine(matchers: [HTTPRequestMatcher]) -> HTTPRequestMatcher {
        let id = matchers.map({ $0.id }).joined(separator: "&")
        return HTTPRequestMatcher(id: id) { (request) -> Bool in
            for matcher in matchers {
                if matcher.matches(request) == false {
                    return false
                }
            }
            return true
        }
    }
    
    static func path(contains component: String) -> HTTPRequestMatcher {
        // setting path as id here so that we don't have multiple predicates for the same path:
        HTTPRequestMatcher(id: "path-contains:\(component)") {
            $0.url?.path.contains(component) ?? false
        }
    }
    
    static func path(equals otherPath: String) -> HTTPRequestMatcher {
        // setting path as id here so that we don't have multiple predicates for the same path:
        HTTPRequestMatcher(id: "path-equals:\(otherPath)") {
            let trim: (String?) -> String? = { $0?.trimmingCharacters(in: CharacterSet(charactersIn: "/")) }
            return trim($0.url?.path) == trim(otherPath)
        }
    }
    
    static func method(equals otherMethod: HTTPMethod) -> HTTPRequestMatcher {
        HTTPRequestMatcher(id: "method-equals:\(otherMethod.rawValue)") {
            $0.method == otherMethod
        }
    }
    
    static func host(equals otherURL: URL) -> HTTPRequestMatcher {
        HTTPRequestMatcher(id: "host-equals:\(otherURL.absoluteString)") {
            $0.url?.host == otherURL.absoluteString
        }
    }
    
    static func headers(equals otherHeaders: HTTPHeaders?) -> HTTPRequestMatcher {
        let id = otherHeaders?.dictionary.map({ $0 + "=" + $1 }).joined(separator: "&") ?? "<nil>"
        return HTTPRequestMatcher(id: "headers-equals:\(id)") {
            $0.headers.dictionary == otherHeaders?.dictionary
        }
    }
    
    static func headers(matches: @escaping (HTTPHeaders) -> Bool) -> HTTPRequestMatcher {
        return HTTPRequestMatcher(id: "headers-matches:\(UUID().uuidString)") {
            matches($0.headers)
        }
    }
    
    static func query(matches: @escaping ([URLQueryItem]?) -> Bool) -> HTTPRequestMatcher {
        HTTPRequestMatcher(id: "query-matches:\(UUID().uuidString)") {
            let components = $0.url.flatMap({ URLComponents(string: $0.absoluteString) })
            return matches(components?.queryItems)
        }
    }
    
    static func body(matches: @escaping (Data?) -> Bool) -> HTTPRequestMatcher {
        HTTPRequestMatcher(id: "body-matches:\(UUID().uuidString)") {
            matches($0.httpBody)
        }
    }
}
