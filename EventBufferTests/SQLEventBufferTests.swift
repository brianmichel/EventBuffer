import XCTest
import EventBuffer

class SQLEventBufferTests: XCTestCase {
    var sut: SQLEventBuffer?

    override func setUp() {
        super.setUp()
        sut = SQLEventBuffer(path: NSURL(string: NSTemporaryDirectory().stringByAppendingString("temp.sqlite"))!)
        sut?.flush({ (events) -> Void in
            // make sure we don't have events
        })
    }
    
    func testBufferingIncrementsCount() {
        let expectation = self.expectationWithDescription("increment buffer count")

        let originalCount = sut?.bufferedEventCount

        sut?.buffer("cool", payload: ["thing": "dood"], callback: { (count: Int) in
            expectation.fulfill()
            XCTAssertEqual(count, (originalCount! + 1), "Buffering an event should increment by exactly 1")
        })

        self.waitForExpectationsWithTimeout(0.1, handler: { (error: NSError!) -> Void in
            println("Did not update buffer in time")
        })
    }

    func testFlushingYieldsAllEvents() {
        let expectation = self.expectationWithDescription("wait for flush")
        sut?.flush({ (events: [BufferedEvent]) -> Void in
            XCTAssertTrue(events.count == 0, "We should not have any events")
            expectation.fulfill()
        })

        self.waitForExpectationsWithTimeout(0.1, handler: { (error: NSError!) -> Void in
            println("Did not flush buffer in time")
        })
    }

    func testBufferedEventsArePassedAfterFlush() {
        sut?.buffer("cool", payload: ["thing": "dood"])

        let expectation = self.expectationWithDescription("wait for flush")
        sut?.flush({ (events: [BufferedEvent]) -> Void in
            XCTAssertTrue(events.count == 1, "We should not have any events")
            expectation.fulfill()
        })

        self.waitForExpectationsWithTimeout(0.1, handler: { (error: NSError!) -> Void in
            println("Did not flush buffer in time")
        })
    }
    
}
