import Foundation

/// A provider object that supplies response stubs for a given URL request.
public protocol HTTPStubProvider {
    func hasStub(for request: URLRequest) -> Bool
    func stub(for request: URLRequest) async throws -> HTTPResponseStub
    func addStub(_ stub: HTTPResponseStub, for matcher: HTTPRequestMatcher)
}

// MARK: - Errors

/// A generic stub provider error.
public enum HTTPStubProviderError: LocalizedError {
    
    /// Could not find a stubbed response registered for the request.
    case unableToFindStubForRequest(URLRequest)
    
    public var errorDescription: String? {
        switch self {
        case .unableToFindStubForRequest(let request):
            return "Could not find a response stub registered for the request: \(request)"
        }
    }
}
