#  Request Loader Chain ⛓️

Multiple `HTTPRequestLoader`s can be combined to act as a single request loader for an API.

A use-case for this could be when you need to stub a portion of your API for a demo or testing.

```swift
let stubProvider = InMemoryStubProvider()
let stubbedRequestLoader = StubbedRequestLoader(provider: stubProvider)
stubbedRequestLoader.configuration.responseScheduler = DelayedResponseScheduler(delay: 1.3)

stubProvider.addStub(
  .success(body: .resource(name: "post", extension: "json", bundle: .module)),
  for: .path(equals: "posts/1")
)

let liveRequestLoader = AlamofireRequestLoader()
let api = BlogAPI(loader: combineRequestLoaders(stubbedRequestLoader, liveRequestLoader))
```

☝️ In the example above, any request without `posts/1` path would be loaded using the live network.
