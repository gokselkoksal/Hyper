import Foundation
import Alamofire

/// A request loader which returns an empty response for all requests.
///
/// Disclaimer: This request loader should not be used in production.
public final class DummyRequestLoader: HTTPRequestLoader {
    
    public func load(_ request: DataRequest) async -> DataResponse<Data, Error> {
        let data = Data()
        return DataResponse(
            request: request.request,
            response: nil,
            data: data,
            metrics: nil,
            serializationDuration: 0,
            result: .success(data)
        )
    }
}
