import XCTest
import Alamofire
@testable import Neat

final class NeatTests: XCTestCase {
    
    private var api: BlogAPI!
    
    override func setUpWithError() throws {
        api = BlogAPI(loader: DummyRequestLoader())
    }
    
    func testExample() throws {
        let task = api.blogPost(id: 12)
        let urlRequest = try XCTUnwrap(task.underlyingURLRequest)
        print("headers", urlRequest.allHTTPHeaderFields)
        print("body", urlRequest.httpBody.map({ try! JSONSerialization.jsonObject(with: $0) }))
        print("method", urlRequest.httpMethod)
    }
}

//extension URLRequest {
//    func assertHeadersEqualTo(_ expectedHeaders: [String: String]?) {
//        switch (allHTTPHeaderFields, expectedHeaders) {
//        case let (.some(actual), .some(expected)):
//            XCTAssertEqual(actual.keys.count, expected.keys.count, "Expected to have")
//            actual.keys
//        }
//        self.allHTTPHeaderFields
//    }
//}

final class DummyRequestLoader: HTTPRequestLoader {
    
    func canLoad(_ request: DataRequest) -> Bool {
        return true
    }
    
    func load(_ request: DataRequest) async -> HTTPDataResponse<Data> {
        let data = Data()
        return DataResponse(
            request: request.request,
            response: nil,
            data: data,
            metrics: nil,
            serializationDuration: 0,
            result: .success(data)
        )
    }
}
