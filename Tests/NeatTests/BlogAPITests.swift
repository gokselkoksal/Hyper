import XCTest
import Alamofire
@testable import Neat

final class NeatTests: XCTestCase {
    
    private var api: BlogAPI!
    
    override func setUpWithError() throws {
        api = BlogAPI(loader: DummyRequestLoader())
    }
    
    func test_blogPost() throws {
        let task = api.blogPost(id: 12)
        let request = try XCTUnwrap(task.underlyingURLRequest)
        try request.assertComponents(
            host: "jsonplaceholder.typicode.com",
            path: "posts/12",
            method: "GET",
            headers: ["Content-Type": "application/json; charset=UTF-8"],
            queryItems: nil
        )
        request.assertBodyIsEmpty()
    }
    
    func test_createBlogPost() throws {
        let post = (
            title: "Alice in Borderland",
            body: "Disappointing",
            userID: 1
        )
        let task = api.createBlogPost(title: post.title, body: post.body, userID: post.userID)
        let request = try XCTUnwrap(task.underlyingURLRequest)
        try request.assertComponents(
            host: "jsonplaceholder.typicode.com",
            path: .posts,
            method: "POST",
            headers: ["Content-Type": "application/json; charset=UTF-8"]
        )
        try request.verifyBody(as: .jsonDictionary()) { body in
            XCTAssertEqual(body["title"] as? String, post.title)
            XCTAssertEqual(body["body"] as? String, post.body)
            XCTAssertEqual(body["userId"] as? Int, post.userID)
        }
    }
    
    func test_updateBlogPost() throws {
        let post = (id: 1, title: "Schildler's List", body: "Masterpiece", userID: 1)
        let task = api.updateBlogPost(id: post.id, title: post.title, body: post.body, userID: post.userID)
        let request = try XCTUnwrap(task.underlyingURLRequest)
        try request.assertComponents(
            host: "jsonplaceholder.typicode.com",
            path: .posts(id: post.id),
            method: "PUT",
            headers: ["Content-Type": "application/json; charset=UTF-8"]
        )
        try request.verifyBody(as: .jsonDictionary()) { body in
            XCTAssertEqual(body["id"] as? Int, post.id)
            XCTAssertEqual(body["title"] as? String, post.title)
            XCTAssertEqual(body["body"] as? String, post.body)
            XCTAssertEqual(body["userId"] as? Int, post.userID)
        }
    }
}

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
