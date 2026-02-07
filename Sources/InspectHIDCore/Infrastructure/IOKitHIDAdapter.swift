import Foundation
import IOKit.hid

/// IOKit HID adapter for accessing USB HID devices
public final class IOKitHIDAdapter: IOKitHIDAdapterProtocol, @unchecked Sendable {

    public init() {}

    /// Enumerate all connected HID devices using IOHIDManager
    public func enumerateDevices() throws -> [any HIDDeviceHandle] {
        // Create HID Manager
        let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))

        // Set device matching to all HID devices
        IOHIDManagerSetDeviceMatching(manager, nil)

        // Open manager
        let openResult = IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        guard openResult == kIOReturnSuccess else {
            return []
        }

        defer {
            IOHIDManagerClose(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        }

        // Copy devices
        guard let deviceSet = IOHIDManagerCopyDevices(manager) else {
            return []
        }

        let devices = (deviceSet as! Set<IOHIDDevice>).map { IOHIDDeviceHandle(device: $0) }
        return devices
    }

    /// Get Vendor ID from IOHIDDevice
    public func getVendorId(_ device: any HIDDeviceHandle) -> UInt16? {
        guard let ioDevice = (device as? IOHIDDeviceHandle)?.device else {
            return nil
        }
        return getIntProperty(ioDevice, key: kIOHIDVendorIDKey).map { UInt16($0) }
    }

    /// Get Product ID from IOHIDDevice
    public func getProductId(_ device: any HIDDeviceHandle) -> UInt16? {
        guard let ioDevice = (device as? IOHIDDeviceHandle)?.device else {
            return nil
        }
        return getIntProperty(ioDevice, key: kIOHIDProductIDKey).map { UInt16($0) }
    }

    /// Get Product Name from IOHIDDevice
    public func getProductName(_ device: any HIDDeviceHandle) -> String? {
        guard let ioDevice = (device as? IOHIDDeviceHandle)?.device else {
            return nil
        }
        return getStringProperty(ioDevice, key: kIOHIDProductKey)
    }

    /// Get Manufacturer from IOHIDDevice
    public func getManufacturer(_ device: any HIDDeviceHandle) -> String? {
        guard let ioDevice = (device as? IOHIDDeviceHandle)?.device else {
            return nil
        }
        return getStringProperty(ioDevice, key: kIOHIDManufacturerKey)
    }

    /// Get Serial Number from IOHIDDevice
    public func getSerialNumber(_ device: any HIDDeviceHandle) -> String? {
        guard let ioDevice = (device as? IOHIDDeviceHandle)?.device else {
            return nil
        }
        return getStringProperty(ioDevice, key: kIOHIDSerialNumberKey)
    }

    // MARK: - Private Helpers

    private func getIntProperty(_ device: IOHIDDevice, key: String) -> Int? {
        guard let value = IOHIDDeviceGetProperty(device, key as CFString) else {
            return nil
        }
        if let number = value as? NSNumber {
            return number.intValue
        }
        return nil
    }

    private func getStringProperty(_ device: IOHIDDevice, key: String) -> String? {
        guard let value = IOHIDDeviceGetProperty(device, key as CFString) else {
            return nil
        }
        return value as? String
    }
}
