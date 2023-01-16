import Foundation
import Alamofire

public final class AlamofireRequestLoader: HTTPRequestLoader {
    public func load(_ request: DataRequest) async -> HTTPDataResponse<Data> {
        await request
            .serializingResponse(using: DataResponseSerializer())
            .response
            .mapError({ $0 as Error })
    }
}
