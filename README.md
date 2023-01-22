# Hyper 🦸

### What is Hyper? 🧱

Hyper is a network abstraction layer which allows building APIs conveniently. It provides a thin layer of models, interfaces and helpers to guide you through...
* creating an API and implementing its endpoints 📚
* providing validation, decoding and retry logic 🧑‍🔧
* and stubbing when necessary 🧪

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
    self.defaultHeaders = HTTPHeaders(["Content-type": "application/json; charset=UTF-8"])
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
    buildTask(with: .jsonDecoder()) { task in
      task.request.method = .get
      task.request.path = .init("posts", "\(id)")
    }
  }
}
```
Then we would consume it like below.
```swift
let api = BlogAPI(taskLoader: HTTPTaskLoader(requestLoaders: [.live()])

cancellables += api.blogPost(id: 1).start { response in
  switch response.result {
  case .success(let post):
    print("Fetch successful! Post: \(post)")
  case .failure(let error):
    print("Fetch failed! Error: \(error)")
  }
}
```

## Stubbing
Hyper comes packed with powerful stubbing capabilities. Any network request can be mocked using a stubbed request loader.

Let's say we want to mock `/posts/<id>` endpoint with the payload below.
```json
{
  "userId": 1,
  "id": 1,
  "title": "Mock post title",
  "body": "Mock post body"
}
```
We would first create the API with a stubbed request loader.
```swift
let stubProvider = HTTPStubProvider.local()
let api = BlogAPI.stubbed(provider: stubProvider)
```
We would then add a stub for the request we would like to mock.
```swift
let task = api.blogPost(id: 1)
try stubProvider.addStub(
  .success(body: .resource(name: "post", extension: "json", bundle: .module)),
  for: .request(task.request)
)
```
Now start the task as usual and run assertions.
```swift
// when the request is started:
var actualResponse: HTTPResponse<Post>?
cancellables += task.start { actualResponse = $0 }

// then expect to receive the mocked post:
let expectedPost = try XCTUnwrap(actualResponse).result.get()
XCTAssertEqual(expectedPost.id, 1)
XCTAssertEqual(expectedPost.userId, 1)
XCTAssertEqual(expectedPost.title, "Mock post title")
XCTAssertEqual(expectedPost.body, "Mock post body")
```
**Note that this test runs synchronously as we provided a stubbed request loader!** :zap:

## Advanced Usage
* [Manual Response Scheduling in Tests](./Docs/Advanced.md#manual-response-scheduling): Lets you control when a request should be responded to in tests to be able to test intermediate state.
* [Request Loader Chain](./Docs/Advanced.md#request-loader-chain): Allows you to use multiple loaders to handle a group of requests differently.
* Request Modifiers: _Docs in progress..._
* Response Modifiers: _Docs in progress..._
* Request Retrier: _Docs in progress..._
* Custom Response Decoding: _Docs in progress..._

## Inspiration
* [HTTP in Swift](https://davedelong.com/blog/2020/06/27/http-in-swift-part-1/): A great 18 part series written by Dave DeLong.
* [Moya](https://github.com/Moya/Moya): A network abstraction layer written in Swift.
