import Foundation
@testable import InspectHIDCore

/// Mock HID device handle for testing
final class MockHIDDeviceHandle: HIDDeviceHandle, @unchecked Sendable {
    let vendorId: UInt16
    let productId: UInt16
    let productName: String?
    let manufacturer: String?
    let serialNumber: String?

    // Device Descriptor properties
    let deviceClass: UInt8?
    let deviceSubClass: UInt8?
    let deviceProtocol: UInt8?
    let versionNumber: UInt16?
    let reportDescriptor: Data?

    init(
        vendorId: UInt16,
        productId: UInt16,
        productName: String?,
        manufacturer: String?,
        serialNumber: String?,
        deviceClass: UInt8? = nil,
        deviceSubClass: UInt8? = nil,
        deviceProtocol: UInt8? = nil,
        versionNumber: UInt16? = nil,
        reportDescriptor: Data? = nil
    ) {
        self.vendorId = vendorId
        self.productId = productId
        self.productName = productName
        self.manufacturer = manufacturer
        self.serialNumber = serialNumber
        self.deviceClass = deviceClass
        self.deviceSubClass = deviceSubClass
        self.deviceProtocol = deviceProtocol
        self.versionNumber = versionNumber
        self.reportDescriptor = reportDescriptor
    }
}

/// Mock IOKit HID adapter for testing
final class MockIOKitHIDAdapter: IOKitHIDAdapterProtocol, @unchecked Sendable {
    private let devices: [MockHIDDeviceHandle]

    init(devices: [MockHIDDeviceHandle]) {
        self.devices = devices
    }

    func enumerateDevices() throws -> [any HIDDeviceHandle] {
        return devices
    }

    func getVendorId(_ device: any HIDDeviceHandle) -> UInt16? {
        guard let mock = device as? MockHIDDeviceHandle else { return nil }
        return mock.vendorId
    }

    func getProductId(_ device: any HIDDeviceHandle) -> UInt16? {
        guard let mock = device as? MockHIDDeviceHandle else { return nil }
        return mock.productId
    }

    func getProductName(_ device: any HIDDeviceHandle) -> String? {
        guard let mock = device as? MockHIDDeviceHandle else { return nil }
        return mock.productName
    }

    func getManufacturer(_ device: any HIDDeviceHandle) -> String? {
        guard let mock = device as? MockHIDDeviceHandle else { return nil }
        return mock.manufacturer
    }

    func getSerialNumber(_ device: any HIDDeviceHandle) -> String? {
        guard let mock = device as? MockHIDDeviceHandle else { return nil }
        return mock.serialNumber
    }

    // MARK: - Device Descriptor Properties

    func getDeviceClass(_ device: any HIDDeviceHandle) -> UInt8? {
        guard let mock = device as? MockHIDDeviceHandle else { return nil }
        return mock.deviceClass
    }

    func getDeviceSubClass(_ device: any HIDDeviceHandle) -> UInt8? {
        guard let mock = device as? MockHIDDeviceHandle else { return nil }
        return mock.deviceSubClass
    }

    func getDeviceProtocol(_ device: any HIDDeviceHandle) -> UInt8? {
        guard let mock = device as? MockHIDDeviceHandle else { return nil }
        return mock.deviceProtocol
    }

    func getVersionNumber(_ device: any HIDDeviceHandle) -> UInt16? {
        guard let mock = device as? MockHIDDeviceHandle else { return nil }
        return mock.versionNumber
    }

    func getReportDescriptor(_ device: any HIDDeviceHandle) -> Data? {
        guard let mock = device as? MockHIDDeviceHandle else { return nil }
        return mock.reportDescriptor
    }
}
