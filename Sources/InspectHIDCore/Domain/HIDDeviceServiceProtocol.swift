import Foundation

/// Protocol for HID device operations - Domain layer
public protocol HIDDeviceServiceProtocol: Sendable {
    /// List all connected HID devices
    func listDevices() throws -> [HIDDeviceInfo]

    /// Get Device Descriptor for specified device
    func getDeviceDescriptor(specifier: DeviceSpecifier) throws -> DeviceDescriptor

    /// Get Report Descriptor raw bytes for specified device
    func getReportDescriptor(specifier: DeviceSpecifier) throws -> Data
}
