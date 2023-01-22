import XCTest
import Hyper

final class BlogAPIStubTests: XCTestCase {
    
    private var api: BlogAPI!
    private var stubProvider: InMemoryStubProvider!
    
    override func setUpWithError() throws {
        stubProvider = InMemoryStubProvider()
        api = BlogAPI(loader: StubbedRequestLoader(provider: stubProvider))
    }

    func test_stub_encodable() async throws {
        let expectedPosts = [
            BlogPost(id: 1, userId: 10, title: "title1", body: "body1"),
            BlogPost(id: 2, userId: 20, title: "title2", body: "body2")
        ]
        stubProvider.addStub(
            .success(body: try .encodable(expectedPosts)),
            for: .combine(
                .path(equals: URL.Path.posts.rawValue),
                .method(equals: .get)
            )
        )
        let actualPosts = try await api.blogPosts().value
        XCTAssertEqual(actualPosts, expectedPosts)
    }
}
