import Foundation
@testable import InspectHIDCore

/// Mock HID device handle for testing
final class MockHIDDeviceHandle: HIDDeviceHandle, @unchecked Sendable {
    let vendorId: UInt16
    let productId: UInt16
    let productName: String?
    let manufacturer: String?
    let serialNumber: String?

    init(
        vendorId: UInt16,
        productId: UInt16,
        productName: String?,
        manufacturer: String?,
        serialNumber: String?
    ) {
        self.vendorId = vendorId
        self.productId = productId
        self.productName = productName
        self.manufacturer = manufacturer
        self.serialNumber = serialNumber
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
}
