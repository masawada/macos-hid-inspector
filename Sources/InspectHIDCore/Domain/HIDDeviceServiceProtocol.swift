import Foundation

/// Protocol for HID device operations - Domain layer
public protocol HIDDeviceServiceProtocol: Sendable {
    /// List all connected HID devices
    func listDevices() throws -> [HIDDeviceInfo]
}
