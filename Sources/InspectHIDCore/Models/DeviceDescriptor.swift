import Foundation

/// Represents USB Device Descriptor information
public struct DeviceDescriptor: Equatable, Codable, Sendable {
    /// USB Device Class code
    public let bDeviceClass: UInt8

    /// USB Device Subclass code
    public let bDeviceSubClass: UInt8

    /// USB Device Protocol code
    public let bDeviceProtocol: UInt8

    /// USB Vendor ID
    public let idVendor: UInt16

    /// USB Product ID
    public let idProduct: UInt16

    /// Device release number in BCD format (e.g., "1.00", "2.10")
    public let bcdDevice: String

    /// Manufacturer string descriptor
    public let iManufacturer: String

    /// Product string descriptor
    public let iProduct: String

    /// Serial number string descriptor
    public let iSerialNumber: String

    public init(
        bDeviceClass: UInt8,
        bDeviceSubClass: UInt8,
        bDeviceProtocol: UInt8,
        idVendor: UInt16,
        idProduct: UInt16,
        bcdDevice: String,
        iManufacturer: String,
        iProduct: String,
        iSerialNumber: String
    ) {
        self.bDeviceClass = bDeviceClass
        self.bDeviceSubClass = bDeviceSubClass
        self.bDeviceProtocol = bDeviceProtocol
        self.idVendor = idVendor
        self.idProduct = idProduct
        self.bcdDevice = bcdDevice
        self.iManufacturer = iManufacturer
        self.iProduct = iProduct
        self.iSerialNumber = iSerialNumber
    }
}
