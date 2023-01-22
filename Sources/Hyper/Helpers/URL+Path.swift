import Foundation

public extension URL {

    struct Path: RawRepresentable, ExpressibleByStringLiteral {

        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(stringLiteral value: StringLiteralType) {
            self.init(rawValue: value)
        }
    }
}
