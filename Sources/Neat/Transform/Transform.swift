import Foundation

public struct Transform<Source, Destination> {
    
    private let _apply: (Source) throws -> Destination
    
    public init(transform: @escaping (_ value: Source) throws -> Destination) {
        self._apply = transform
    }
    
    public func apply(_ value: Source) throws -> Destination {
        try _apply(value)
    }
    
    public func map<NewValue>(_ transform: @escaping (_ value: Destination) throws -> NewValue) -> Transform<Source, NewValue> {
        Transform<Source, NewValue> { value in
            try transform(try _apply(value))
        }
    }
}

// MARK: - Error

extension Transform {
    
    /// Thrown when transform fails.
    public struct Error: Swift.Error {
        
        /// Descriptive message for the error.
        public let message: String
        
        public init(message: String = "Unable to transform from \(Source.self) to \(Destination.self)") {
            self.message = message
        }
    }
}

// MARK: - Convenience

public typealias DataTransform<Value> = Transform<Data, Value>

public extension Data {
    func decode<T>(with transform: Transform<Data, T>) throws -> T {
        try transform.apply(self)
    }
}
