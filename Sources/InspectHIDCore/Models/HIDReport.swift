import Foundation

/// Represents a HID Report received from a device
public struct HIDReport: Equatable, Sendable {
    /// Timestamp when the report was received
    public let timestamp: Date

    /// Raw report data bytes
    public let data: Data

    /// Report ID (0 if device doesn't use report IDs)
    public let reportId: Int

    public init(timestamp: Date, data: Data, reportId: Int) {
        self.timestamp = timestamp
        self.data = data
        self.reportId = reportId
    }
}
