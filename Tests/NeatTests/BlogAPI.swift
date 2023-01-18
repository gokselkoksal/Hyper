import Foundation
import Alamofire
import Neat

final class BlogAPI: APIClient {
    
    let session: Alamofire.Session
    let baseURL: () -> URL
    let defaultHeaders: () -> HTTPHeaders
    let loader: HTTPRequestLoader
    
    init(loader: HTTPRequestLoader) {
        self.session = Alamofire.Session()
        self.baseURL = { URL(string: "https://jsonplaceholder.typicode.com")! }
        self.loader = loader
        self.defaultHeaders = { HTTPHeaders(["Content-type": "application/json; charset=UTF-8"]) }
    }
}

extension BlogAPI {
    
    func blogPost(id: Int) -> HTTPTask<BlogPost> {
        request(path: .posts(id: id), method: .get)
            .decodingValue(as: BlogPost.self)
    }
    
    func blogPosts() -> HTTPTask<[BlogPost]> {
        request(path: .posts, method: .get)
            .decodingValue(as: [BlogPost].self)
    }

    func createBlogPost(title: String?, body: String?, userID: Int) -> HTTPTask<BlogPost> {
        request(
            path: .posts,
            method: .post,
            parameters: .jsonEncoded(["title": title, "body": body, "userId": userID])
        ).decodingValue()
    }

    func updateBlogPost(id: Int, title: String?, body: String?, userID: Int) -> HTTPTask<BlogPost> {
        request(
            path: .posts(id: id),
            method: .put,
            parameters: .jsonEncoded(["id": id, "title": title, "body": body, "userId": userID])
        ).decodingValue()
    }

    func comments(forBlogPostID id: Int) -> HTTPTask<[Comment]> {
        request(path: .posts(id: id), method: .get).decodingValue()
    }
}

// MARK: Models

struct BlogPost: Decodable, Equatable {
    let id: Int
    let userId: Int
    let title: String?
    let body: String?
}

struct Comment: Decodable {
    let id: Int
    let postId: Int
    let name: String?
    let email: String
    let body: String?
}

extension URL.Path {

    static var posts: Self {
        "posts"
    }
    
    static func posts(id: Int) -> Self {
        URL.Path(rawValue: "posts/\(id)")
    }
}
