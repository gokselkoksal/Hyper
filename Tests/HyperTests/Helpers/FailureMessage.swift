import XCTest

struct FailureMessage: ExpressibleByStringLiteral {
    var text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}

extension FailureMessage {
    
    static func expectedCountEqualTo(_ expectedCount: Int, got actualCount: Int) -> FailureMessage {
        FailureMessage("Expected \(expectedCount) items, got \(actualCount)")
    }
    
    static func expectedValueEqualTo(_ expectedValue: Any?, got actualValue: Any?) -> FailureMessage {
        FailureMessage("Expected \(expectedValue.prettyDescription), got \(actualValue.prettyDescription)")
    }
}

func XCTFail(_ message: FailureMessage, file: StaticString = #file, line: UInt = #line) {
    XCTFail(message.text, file: file, line: line)
}
