import Foundation
import Alamofire

/// A live request loader which is powered by Alamofire.
public final class AlamofireRequestLoader: HTTPRequestLoader {
    
    public func load(_ request: DataRequest) async -> DataResponse<Data, Error> {
        await request
            .serializingResponse(using: DataResponseSerializer())
            .response
            .mapError({ $0 as Error })
    }
}
