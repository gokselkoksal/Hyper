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
        
        public static func path(_ components: String...) -> Path {
            Path(rawValue: components.joined(separator: "/"))
        }
    }
}
