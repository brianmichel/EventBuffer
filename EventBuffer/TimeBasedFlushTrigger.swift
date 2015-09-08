//
//  TimeBasedFlushTrigger.swift
//  EventBuffer
//
//  Created by Brian Michel on 9/7/15.
//  Copyright (c) 2015 Brian Michel. All rights reserved.
//

import Foundation

public class TimeBasedFlushTrigger: TimedFlushTrigger {
    private let triggerCallback: FlushTriggerCallback
    private let triggerInterval: NSTimeInterval

    private var flushTimer: NSTimer?

    public var interval: NSTimeInterval {
        return triggerInterval
    }

    required public init(interval: NSTimeInterval, callback: FlushTriggerCallback) {
        triggerCallback = callback
        triggerInterval = interval
    }

    deinit {
        flushTimer?.invalidate()
    }

    //MARK: - FlushTrigger Conformancei
    public func pause() {
        teardownFlushTimer()
    }

    public func reset() {
        setupFlushTimer()
    }

    //MARK: - Public out of necessity
    public func flushTimerFired(timer: NSTimer) {
        triggerCallback(trigger: self)
    }

    //MARK: - Private
    private func setupFlushTimer() {
        teardownFlushTimer()
        flushTimer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: "flushTimerFired:", userInfo: nil, repeats: true)
    }

    private func teardownFlushTimer() {
        flushTimer?.invalidate()
    }
}