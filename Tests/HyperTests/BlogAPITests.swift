import XCTest
import Alamofire
@testable import Hyper

final class BlogAPITests: XCTestCase {
    
    private var api: BlogAPI!
    
    override func setUpWithError() throws {
        api = BlogAPI(loader: DummyRequestLoader())
    }
    
    func test_blogPost() throws {
        let task = api.blogPost(id: 12)
        let request = try XCTUnwrap(task.underlyingURLRequest)
        try request.assertContentsEqualTo(
            baseURL: .jsonPlaceholderAPI,
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
        try request.assertContentsEqualTo(
            baseURL: .jsonPlaceholderAPI,
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
        let post = (id: 1, title: "Schindler's List", body: "Masterpiece", userID: 1)
        let task = api.updateBlogPost(id: post.id, title: post.title, body: post.body, userID: post.userID)
        let request = try XCTUnwrap(task.underlyingURLRequest)
        try request.assertContentsEqualTo(
            baseURL: .jsonPlaceholderAPI,
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
    
    func test_comments() throws {
        let task = api.comments(forBlogPostID: 1)
        let request = try XCTUnwrap(task.underlyingURLRequest)
        try request.assertContentsEqualTo(
            baseURL: .jsonPlaceholderAPI,
            path: .comments,
            method: "GET",
            headers: ["Content-Type": "application/json; charset=UTF-8"],
            queryItems: [URLQueryItem(name: "postId", value: "1")]
        )
        request.assertBodyIsEmpty()
    }
}
