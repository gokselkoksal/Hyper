import Foundation
import Alamofire

/// A request loader which returns stubbed responses. This loader only responds to requests if it has a stub for the
/// given request.
public final class StubbedRequestLoader: HTTPRequestLoader {
    
    /// Thrown when stubbing is not enabled but `load` is called anyway.
    public struct NotEnabledError: LocalizedError {
        public var errorDescription: String? {
            "Stubbing is not enabled."
        }
    }
    
    public struct Configuration {
        
        public static let `default` = Configuration()
        
        /// True if stub provider is enabled.
        public var isEnabled: Bool
        
        /// A scheduler to control
        public var responseScheduler: HTTPResponseScheduler
        
        public init(isEnabled: Bool = true, responseScheduler: HTTPResponseScheduler = ImmediateResponseScheduler()) {
            self.isEnabled = isEnabled
            self.responseScheduler = responseScheduler
        }
    }
    
    public let provider: HTTPStubProvider
    public var configuration: Configuration
    
    public init(provider: HTTPStubProvider, configuration: Configuration = Configuration()) {
        self.provider = provider
        self.configuration = configuration
    }
    
    public func canRespond(to request: DataRequest) -> Bool {
        guard configuration.isEnabled, let urlRequest = request.convertible.urlRequest else { return false }
        return provider.hasStub(for: urlRequest)
    }
    
    public func load(_ request: DataRequest) async -> DataResponse<Data, Error> {
        guard configuration.isEnabled else {
            return DataResponse.failure(request: nil, error: NotEnabledError())
        }
        return await configuration.responseScheduler.schedule {
            let urlRequest: URLRequest
            do {
                urlRequest = try request.convertible.asURLRequest()
            } catch {
                return DataResponse.failure(request: nil, error: error)
            }
            let stub: HTTPResponseStub
            do {
                stub = try await provider.stub(for: urlRequest)
            } catch {
                return DataResponse.failure(request: urlRequest, error: error)
            }
            return DataResponse.stub(request: urlRequest, response: stub)
        }
    }
}
