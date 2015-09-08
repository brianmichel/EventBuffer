import Foundation
import SQLite

public class SQLEventBuffer: PersistentEventBuffer {
    private let db: Database
    private var events: Query {
        return db["events"]
    }
    
    lazy public var processingQueue: dispatch_queue_t = {
        return dispatch_queue_create("com.bsm.sql-event-buffer.processing-queue", DISPATCH_QUEUE_SERIAL)
    }()

    struct Constants {
        static let id = Expression<Int64>("id")
        static let eventName = Expression<String>("event_name")
        static let eventTime = Expression<Int64>("event_time")
        static let eventValue = Expression<String>("event_value")
    }

    public var bufferedEventCount: Int {
        return events.count
    }

    required public init(path: NSURL) {
        if let absolutePath = path.absoluteString {
            db = Database(absolutePath)

            configureTable(events, db: db)
        }
        else {
            fatalError("Unable to initialize persistent event buffer")
        }
    }

    public func buffer(name: String, payload: [String : AnyObject], callback: BufferCallback? = nil) {
        dispatch_async(processingQueue, { () -> Void in
            var error: NSError?

            if let jsonValue = NSJSONSerialization.dataWithJSONObject(payload, options: .allZeros, error: &error),
                stringValue = NSString(data: jsonValue, encoding: NSUTF8StringEncoding) as? String {
                let timestamp = NSDate().timeIntervalSince1970
                self.events.insert(
                    Constants.eventName <- name,
                    Constants.eventTime <- Int64(timestamp),
                    Constants.eventValue <- stringValue
                    )

                    callback?(self.bufferedEventCount)
            }
            else {
                print("Error serializing payload \(error)")
            }
        })
    }

    public func flush(callback: FlushCallback) {
        dispatch_async(processingQueue, { () -> Void in
            if self.events.isEmpty {
                callback([])
            }
            else {
                let all = Array(self.events)

                let events = all.map({ (row: Row) -> BufferedEvent in
                    let event = BufferedEvent(
                        name: row[Constants.eventName],
                        timestamp: row[Constants.eventTime],
                        payload: row[Constants.eventValue]
                    )

                    return event
                })
                callback(events)
                self.events.delete()
            }
        })
    }

    private func configureTable(table: Query, db: Database) {
        db.create(table: table, ifNotExists: true) { t in
            t.column(Constants.id, primaryKey: true)
            t.column(Constants.eventName)
            t.column(Constants.eventValue)
            t.column(Constants.eventTime)
        }
    }
}