import Foundation
import IOKit.hid

/// Abstract handle for HID device - allows mocking in tests
/// This protocol wraps IOHIDDevice for testability
public protocol HIDDeviceHandle: Sendable {}

/// Wrapper around IOHIDDevice for production use
public final class IOHIDDeviceHandle: HIDDeviceHandle, @unchecked Sendable {
    let device: IOHIDDevice

    init(device: IOHIDDevice) {
        self.device = device
    }
}
