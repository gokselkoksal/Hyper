import Foundation

public final class InMemoryStubProvider: HTTPStubProvider {
    
    private var stubs: [HTTPRequestMatcher: HTTPResponseStub]
    
    public init(stubs: [HTTPRequestMatcher : HTTPResponseStub] = [:]) {
        self.stubs = stubs
    }
    
    public func hasStub(for request: URLRequest) -> Bool {
        stubs.keys.contains(where: { $0.matches(request) })
    }
    
    public func stub(for request: URLRequest) async throws -> HTTPResponseStub {
        guard let stub = stubs.first(where: { $0.key.matches(request) }) else {
            throw HTTPStubProviderError.unableToFindStubForRequest(request)
        }
        return stub.value
    }
    
    public func addStub(_ stub: HTTPResponseStub, for matcher: HTTPRequestMatcher) {
        stubs[matcher] = stub
    }
}
