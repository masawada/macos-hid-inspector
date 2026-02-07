import Foundation

/// Represents information about a connected HID device
public struct HIDDeviceInfo: Equatable, Codable, Sendable {
    /// Index number for device selection (0-based)
    public let index: Int

    /// USB Vendor ID
    public let vendorId: UInt16

    /// USB Product ID
    public let productId: UInt16

    /// Product name from device descriptor
    public let productName: String

    /// Manufacturer name from device descriptor
    public let manufacturer: String

    /// Serial number from device descriptor
    public let serialNumber: String

    public init(
        index: Int,
        vendorId: UInt16,
        productId: UInt16,
        productName: String,
        manufacturer: String,
        serialNumber: String
    ) {
        self.index = index
        self.vendorId = vendorId
        self.productId = productId
        self.productName = productName
        self.manufacturer = manufacturer
        self.serialNumber = serialNumber
    }
}
