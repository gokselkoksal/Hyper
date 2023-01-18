import Foundation
import XCTest
import Neat

extension URLRequest {
    
    func verifyBody<Contents>(transform: (Data) throws -> Contents, verify: (_ body: Contents) throws -> Void) throws {
        let contents = try XCTUnwrap(try httpBody.map(transform))
        try verify(contents)
    }
    
    func verifyBody<T>(as transform: BodyTransform<T>, verify: (_ body: T) throws -> Void) throws {
        try verifyBody(transform: transform.apply(to:), verify: verify)
    }
    
    func assertBodyIsEmpty() {
        guard let httpBody else { return }
        if httpBody.isEmpty == false {
            XCTFail(.expectedValueEqualTo("<nil> or <empty>", got: httpBody))
        }
    }
}

// MARK: - BodyTransform

struct BodyTransform<Contents> {
    
    private let transform: (Data) throws -> Contents
    
    init(_ transform: @escaping (Data) throws -> Contents) {
        self.transform = transform
    }
    
    func apply(to body: Data) throws -> Contents {
        try transform(body)
    }
}

extension BodyTransform {
    
    init(transform: Transform<Data, Contents>) {
        self.init(transform.apply)
    }
}

extension BodyTransform where Contents == [String: Any] {
    static func jsonDictionary(options: JSONSerialization.ReadingOptions = []) -> Self {
        BodyTransform(transform: .jsonDictionaryDecoder(options: options))
    }
}

extension BodyTransform where Contents == Any {
    static func jsonObject(options: JSONSerialization.ReadingOptions = []) -> Self {
        BodyTransform(transform: .jsonObjectTransform(options: options))
    }
}

extension BodyTransform where Contents: Decodable {
    static func decodable(_ type: Contents.Type = Contents.self, decoder: JSONDecoder = JSONDecoder()) -> Self {
        BodyTransform(transform: .decodableTransform(using: decoder))
    }
}
