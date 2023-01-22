import Foundation

public extension URL {

    struct Path: RawRepresentable, ExpressibleByStringLiteral {

        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        }

        public init(stringLiteral value: StringLiteralType) {
            self.init(rawValue: value)
        }
        
        public static func path(_ components: URLPathValueConvertible...) -> Path {
            Path(rawValue: components.map({ $0.pathValue }).joined(separator: "/"))
        }
    }
}

public protocol URLPathValueConvertible {
    var pathValue: String { get }
}
 
extension String: URLPathValueConvertible {
    public var pathValue: String {
        self
    }
}

extension Int: URLPathValueConvertible {
     public var pathValue: String {
        String(describing: self)
    }
}
