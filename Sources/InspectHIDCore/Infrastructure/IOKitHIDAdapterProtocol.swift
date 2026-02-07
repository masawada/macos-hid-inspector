import Foundation

/// Protocol for IOKit HID operations - allows dependency injection and testing
public protocol IOKitHIDAdapterProtocol: Sendable {
    /// Enumerate all connected HID devices
    func enumerateDevices() throws -> [any HIDDeviceHandle]

    /// Get Vendor ID from device
    func getVendorId(_ device: any HIDDeviceHandle) -> UInt16?

    /// Get Product ID from device
    func getProductId(_ device: any HIDDeviceHandle) -> UInt16?

    /// Get Product Name from device
    func getProductName(_ device: any HIDDeviceHandle) -> String?

    /// Get Manufacturer from device
    func getManufacturer(_ device: any HIDDeviceHandle) -> String?

    /// Get Serial Number from device
    func getSerialNumber(_ device: any HIDDeviceHandle) -> String?

    // MARK: - Device Descriptor Properties

    /// Get USB Device Class from device
    func getDeviceClass(_ device: any HIDDeviceHandle) -> UInt8?

    /// Get USB Device Subclass from device
    func getDeviceSubClass(_ device: any HIDDeviceHandle) -> UInt8?

    /// Get USB Device Protocol from device
    func getDeviceProtocol(_ device: any HIDDeviceHandle) -> UInt8?

    /// Get device version number (bcdDevice) from device
    func getVersionNumber(_ device: any HIDDeviceHandle) -> UInt16?

    /// Get HID Report Descriptor raw bytes from device
    func getReportDescriptor(_ device: any HIDDeviceHandle) -> Data?
}
