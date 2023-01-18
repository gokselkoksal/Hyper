import Foundation

extension URLComponents {
    
    func assertScheme(_ expectedScheme: String?, file: StaticString = #file, line: UInt = #line) {
        assertOptionalsEqual(expectedValue: expectedScheme, actualValue: scheme, file: file, line: line)
    }
    
    func assertHost(_ expectedHost: String?, file: StaticString = #file, line: UInt = #line) {
        assertOptionalsEqual(expectedValue: expectedHost, actualValue: host, file: file, line: line)
    }
    
    func assertPath(_ expectedPath: String, file: StaticString = #file, line: UInt = #line) {
        let pathSeparator = CharacterSet(charactersIn: "/")
        let trim: (String) -> String = { $0.trimmingCharacters(in: pathSeparator) }
        let actualPath = trim(path)
        let expectedPath = trim(expectedPath)
        if actualPath != expectedPath {
            XCTFail(.expectedValueEqualTo(expectedPath, got: actualPath), file: file, line: line)
        }
    }
    
    func assertQueryItems(_ expectedQueryItems: [URLQueryItem]?, file: StaticString = #file, line: UInt = #line) {
        assertOptionals(expectedValue: expectedQueryItems, actualValue: queryItems, file: file, line: line) { expectedQueryItems, actualQueryItems in
            if actualQueryItems.count != expectedQueryItems.count {
                XCTFail(.expectedCountEqualTo(expectedQueryItems.count, got: actualQueryItems.count), file: file, line: line)
            } else {
                let describe: ([URLQueryItem]) -> String = { items in
                    items.sorted(by: { $0.name < $1.name })
                        .map({ "\($0.name)=\($0.value ?? "")" })
                        .joined(separator: "&")
                }
                let set = Set(actualQueryItems)
                for expectedQueryItem in expectedQueryItems {
                    if set.contains(expectedQueryItem) == false {
                        XCTFail(
                            .expectedValueEqualTo(describe(expectedQueryItems), got: describe(actualQueryItems)),
                            file: file,
                            line: line
                        )
                    }
                }
            }
        }
    }
}
