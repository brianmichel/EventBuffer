import Foundation

public struct BufferedEvent {
    let name: String
    let timestamp: Int64
    let payload: String

    lazy var deserializedPayload: [String: AnyObject]? = {
        var error: NSError?
        let data = self.payload.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        if let payloadData = data, returnPayload = NSJSONSerialization.JSONObjectWithData(payloadData,
            options: NSJSONReadingOptions.allZeros,
            error: &error) as? [String: AnyObject] {
            return returnPayload
        }
        return nil
    }()

    init(name: String, timestamp: Int64, payload: String) {
        self.name = name
        self.timestamp = timestamp
        self.payload = payload
    }
}