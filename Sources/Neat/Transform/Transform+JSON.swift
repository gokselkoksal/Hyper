import Foundation

public extension Transform where Source == Data, Destination == [String: Any] {
    
    static func jsonDictionaryDecoder(options: JSONSerialization.ReadingOptions = []) -> Self {
        DataTransform<Any>.jsonObjectTransform(options: options).map { jsonObject in
            guard let jsonDictionary = jsonObject as? [String: Any] else {
                throw Self.Error(message: "Unable to transform JSON object into a dictionary. Value: \(jsonObject)")
            }
            return jsonDictionary
        }
    }
}

public extension Transform where Source == Data, Destination == Any {
    
    static func jsonObjectTransform(options: JSONSerialization.ReadingOptions) -> Self {
        Transform { data in
            try JSONSerialization.jsonObject(with: data, options: options)
        }
    }
}
