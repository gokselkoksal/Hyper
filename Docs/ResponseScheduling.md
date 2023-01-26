#  Response Scheduling

`StubbedRequestLoader` can be configured to schedule responses with delay.

```swift
let stubProvider = InMemoryStubProvider()
let configuration = StubbedRequestLoader.Configuration(
  isEnabled: true,
  responseScheduler: DelayedResponseScheduler(delay: 1.3)
)
let loader = StubbedRequestLoader(
  provider: stubProvider,
  configuration: configuration 
)
```

☝️ Request loader above would load stubbed responses with 1.3 seconds delay to mimic a real network. If no value is provided, responses are scheduled immediately. 
