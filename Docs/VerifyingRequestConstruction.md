# Verifying Request Construction

Each endpoint on an API can be designed in two ways. First and the most obvious option is having something like below.

```swift
protocol BlogAPI {
  func blogPost(id: Int) async throws -> BlogPost
}
```

While this option is very clean on the call site, it's not possible to inspect and verify the underlying URL request in any way. Requests would be executed right away when we call this method.

Second option would be to return an `HTTPTask` instead.

```swift
protocol BlogAPI {
  func blogPost(id: Int) -> HTTPTask<BlogPost>
}
```

When we return an `HTTPTask` instead, the request wouldn't be executed right away until we call its `value` property explicitly. This would give us an opportunity to test if the underlying URL request is constructed correctly, without hitting the live network.

See the snippet below from [BlogAPITests.swift](Tests/HyperTests/BlogAPITests.swift) below.

```swift
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
}
```
