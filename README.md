# Hyper 🦸

### What is Hyper? 🧱

Hyper is a network abstraction layer powered by Alamofire. It provides convenience helpers to...
* create HTTP clients and define endpoints using structured concurrency 📚
* provide stubbed responses to HTTP requests 🧪

## Basic Usage
Let's say we have an endpoint like below to fetch a post from my blog.
```
GET https://api.myblog.com/posts/1
```
A successful request would return a JSON response similar to the one below.
```json
{
  "id": 1,
  "title": "Donec sed odio dui.",
  "body": "Cras mattis consectetur purus sit amet fermentum. Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit.",
  "userId": 1
}
```
To build this API using Hyper, we would first define an `APIClient` type.
```swift
final class BlogAPI: APIClient {

  let requestLoader: HTTPRequestLoader
  let baseURL: () -> URL
  let defaultHeaders: () -> HTTPHeaders
  
  init(requestLoader: HTTPRequestLoader) {
    self.requestLoader = requestLoader
    self.baseURL = { URL(string: "https://api.myblog.com")! }
    self.defaultHeaders = { HTTPHeaders(["Content-type": "application/json; charset=UTF-8"]) }
  }
}
```
Then we would add the following endpoint as a function to this API.
```swift
struct BlogPost: Decodable, Equatable {
  let id: Int
  let userId: Int
  let title: String?
  let body: String?
}

extension BlogAPI {

  func blogPost(id: Int) -> HTTPTask<BlogPost> {
    task(path: .posts(id: id), method: .get)
        .decodingValue(as: BlogPost.self)
  }
}
```
Then we would consume it like below.
```swift
let api = BlogAPI(requestLoader: AlamofireRequestLoader())
let blogPost = try await api.blogPost(id: 1).value
```

[See the full `BlogAPI` definition here.](/Tests/HyperTests/Models/BlogAPI.swift)

## Stubbing
Hyper comes packed with powerful stubbing capabilities. Any network request can be mocked using a stubbed request loader.

Let's say we want to mock `/posts/<id>` endpoint with the payload below.
```json
{
  "userId": 1,
  "id": 10,
  "title": "Fake post title",
  "body": "Fake post body"
}
```
We would first create the API with a stubbed request loader.
```swift
let stubProvider = InMemoryStubProvider()
let api = BlogAPI(loader: StubbedRequestLoader(provider: stubProvider))
```
We would then add a stub for the request we would like to mock.
```swift
stubProvider.addStub(
  .success(body: .resource(name: "post", extension: "json", bundle: .module)),
  for: .path(equals: "posts/1")
)
```
Now start the task as usual and run assertions.
```swift
let blogPost = try await api.blogPost(id: 1).value

XCTAssertEqual(blogPost.id, 1)
XCTAssertEqual(blogPost.userId, 10)
XCTAssertEqual(blogPost.title, "Fake post title")
XCTAssertEqual(blogPost.body, "Fake post body")
```

## Core Features
* [Verifying Request Construction](Docs/VerifyingRequestConstruction.md): Using `HTTPTask` abstraction, it's easy to verify underlying `URLRequest` for each endpoint without hitting the live network.
* [Response Scheduling](Docs/ResponseScheduling.md): Stub responses can be served with delay to mimic a real network. 
* [Request Loader Chain](Docs/RequestLoaderChain.md): Allows you to use multiple loaders to handle a group of requests differently.

## Inspiration
* [HTTP in Swift](https://davedelong.com/blog/2020/06/27/http-in-swift-part-1/): A great 18 part series written by Dave DeLong.
* [Moya](https://github.com/Moya/Moya): A network abstraction layer written in Swift.
