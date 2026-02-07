import Foundation

/// Represents a way to specify a target HID device
public enum DeviceSpecifier: Equatable, Sendable {
    /// Specify device by index number from list command
    case index(Int)

    /// Specify device by Vendor ID and Product ID
    case vidPid(vendorId: UInt16, productId: UInt16)
}
