import Foundation

public typealias FlushTriggerCallback = (trigger: FlushTrigger) -> (Void)

public protocol FlushTrigger {
    func pause()
    func reset()
}

public protocol CountedFlushTrigger: FlushTrigger {
    var count: UInt { get }
    init(count: UInt, callback: FlushTriggerCallback)

    func eventDidBuffer()
}

public protocol TimedFlushTrigger: FlushTrigger {
    var interval: NSTimeInterval { get }
    init(interval: NSTimeInterval, callback: FlushTriggerCallback)
}