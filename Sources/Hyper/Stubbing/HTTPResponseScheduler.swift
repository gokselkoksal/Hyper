import Foundation
import Alamofire

public protocol HTTPResponseScheduler {
    func schedule(_ work: () async -> DataResponse<Data, Error>) async -> DataResponse<Data, Error>
}

// MARK: - Immediate

/// Schedules the response immediately without any changes.
public final class ImmediateResponseScheduler: HTTPResponseScheduler {
    
    public init() { }
    
    public func schedule(_ work: () async -> DataResponse<Data, Error>) async -> DataResponse<Data, Error> {
        await work()
    }
}

// MARK: - Suspended

/// Does not schedule the response unless `resume()` is called.
public final class SuspendedResponseScheduler: HTTPResponseScheduler {
    
    private var completions: [() -> Void] = []
    
    public init() { }
    
    public func schedule(_ work: () async -> DataResponse<Data, Error>) async -> DataResponse<Data, Error> {
        let response = await work()
        return await withCheckedContinuation { contination in
            self.completions.append {
                contination.resume(returning: response)
            }
        }
    }
    
    public func resume() {
        while completions.count > 0 {
            let completion = completions.removeFirst()
            completion()
        }
    }
}

// MARK: - Delayed

/// Schedules the response with some delay.
public final class DelayedResponseScheduler: HTTPResponseScheduler {
    
    public var delay: TimeInterval?
    
    public init(delay: TimeInterval? = nil) {
        self.delay = delay
    }
    
    public func schedule(_ work: () async -> DataResponse<Data, Error>) async -> DataResponse<Data, Error> {
        if let delay {
            do {
                try await Task.sleep(seconds: delay)
            } catch {
                return DataResponse.failure(request: nil, error: error)
            }
        }
        return await work()
    }
}

private extension Task where Success == Never, Failure == Never {
    
    static func sleep(seconds: TimeInterval) async throws {
        let nanoseconds = seconds * TimeInterval(NSEC_PER_SEC)
        try await Self.sleep(nanoseconds: UInt64(nanoseconds))
    }
}
