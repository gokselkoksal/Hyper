import Foundation

public extension Transform where Source == Data, Destination: Decodable {
    
    static func decodableTransform(using jsonDecoder: JSONDecoder = JSONDecoder()) -> Self {
        Transform { data in
            try jsonDecoder.decode(Destination.self, from: data)
        }
    }
}

public extension Data {
    
    func decode<T: Decodable>(as type: T.Type = T.self, jsonDecoder: JSONDecoder = JSONDecoder()) throws -> T {
        try decode(with: .decodableTransform(using: jsonDecoder))
    }
}
