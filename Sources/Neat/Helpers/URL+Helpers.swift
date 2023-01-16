import Foundation

public extension URL {

    init(baseURL: URL, path pathComponents: String...) {
        self = baseURL.appendingPathComponent(pathComponents.joined(separator: "/"))
    }
}
