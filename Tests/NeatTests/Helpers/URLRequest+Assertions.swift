import Foundation
import XCTest
import Neat

extension URL {
    var components: URLComponents? {
        URLComponents(string: absoluteString)
    }
}

extension URLRequest {
    
    func assertMethod(_ expectedMethod: String?, file: StaticString = #file, line: UInt = #line) {
        assertOptionalsEqual(expectedValue: expectedMethod, actualValue: httpMethod, file: file, line: line)
    }
    
    func assertHeaders(_ expectedHeaders: [String: String]?, file: StaticString = #file, line: UInt = #line) {
        assertOptionals(expectedValue: expectedHeaders, actualValue: allHTTPHeaderFields, file: file, line: line) { expectedHeaders, actualHeaders in
            if actualHeaders.count != expectedHeaders.count {
                XCTFail(.expectedCountEqualTo(expectedHeaders.count, got: actualHeaders.count), file: file, line: line)
            } else {
                for (key, actualValue) in actualHeaders {
                    let expectedValue = expectedHeaders[key]
                    if actualValue != expectedValue {
                        XCTFail(.expectedValueEqualTo(expectedHeaders, got: actualHeaders), file: file, line: line)
                    }
                }
            }
        }
    }
    
    func assertComponents(
        scheme: String = "https",
        host: String? = nil,
        path: URL.Path,
        method: String? = nil,
        headers: [String : String]? = nil,
        queryItems: [URLQueryItem]? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        let urlComponents = try XCTUnwrap(url?.components)
        urlComponents.assertHost(host, file: file, line: line)
        urlComponents.assertPath(path.rawValue, file: file, line: line)
        urlComponents.assertQueryItems(queryItems, file: file, line: line)
        assertMethod(method, file: file, line: line)
        assertHeaders(headers, file: file, line: line)
    }
}
