import Foundation

public typealias BufferCallback = (Int) -> Void
public typealias FlushCallback = ([BufferedEvent]) -> Void

public protocol EventBuffer {
    var bufferedEventCount: Int { get }
    var processingQueue: dispatch_queue_t { get }
    func buffer(name: String, payload: [String: AnyObject], callback: BufferCallback?)
    func flush(callback: FlushCallback)
}

public protocol PersistentEventBuffer: EventBuffer {
    init(path: NSURL)
}
