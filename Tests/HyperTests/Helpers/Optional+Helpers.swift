import XCTest

extension Optional {
    var prettyDescription: String {
        switch self {
        case .some(let value):
            return String(describing: value)
        case .none:
            return "<nil>"
        }
    }
}

func assertOptionals<T>(expectedValue: Optional<T>, actualValue: Optional<T>, file: StaticString = #file, line: UInt = #line, verify: (_ expectedValue: T, _ actualValue: T) throws -> Void) rethrows {
    switch (expectedValue, actualValue) {
    case let (.some(expectedValue), .some(actualValue)):
        try verify(expectedValue, actualValue)
    case (.none, .none):
        break
    default:
        XCTFail(.expectedValueEqualTo(expectedValue, got: actualValue), file: file, line: line)
    }
}

func assertOptionalsEqual<T: Equatable>(expectedValue: Optional<T>, actualValue: Optional<T>, message: FailureMessage? = nil, file: StaticString = #file, line: UInt = #line) {
    assertOptionals(expectedValue: expectedValue, actualValue: actualValue) { expectedValue, actualValue in
        if expectedValue != actualValue {
            let message = message ?? .expectedValueEqualTo(expectedValue, got: actualValue)
            XCTFail(message, file: file, line: line)
        }
    }
}
