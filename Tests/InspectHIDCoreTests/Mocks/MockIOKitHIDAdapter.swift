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
    private(set) var openedDevices: [MockHIDDeviceHandle] = []
    private var inputCallbacksWithId: [ObjectIdentifier: (Int, Data) -> Void] = [:]
    private var removalCallbacks: [ObjectIdentifier: () -> Void] = [:]
    private(set) var stopRunLoopCalled: Bool = false

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

    // MARK: - Monitoring Methods

    func open(_ device: any HIDDeviceHandle) throws {
        try open(device, exclusive: true)
    }

    func open(_ device: any HIDDeviceHandle, exclusive: Bool) throws {
        guard let mock = device as? MockHIDDeviceHandle else {
            throw InspectHIDError.ioKitError(code: -1)
        }
        openedDevices.append(mock)
    }

    func close(_ device: any HIDDeviceHandle) {
        guard let mock = device as? MockHIDDeviceHandle else { return }
        openedDevices.removeAll { $0 === mock }
        let id = ObjectIdentifier(mock)
        inputCallbacksWithId.removeValue(forKey: id)
        removalCallbacks.removeValue(forKey: id)
    }

    func registerInputReportCallbackWithId(_ device: any HIDDeviceHandle, callback: @escaping (Int, Data) -> Void) {
        guard let mock = device as? MockHIDDeviceHandle else { return }
        let id = ObjectIdentifier(mock)
        inputCallbacksWithId[id] = callback
    }

    func registerRemovalCallback(_ device: any HIDDeviceHandle, callback: @escaping () -> Void) {
        guard let mock = device as? MockHIDDeviceHandle else { return }
        let id = ObjectIdentifier(mock)
        removalCallbacks[id] = callback
    }

    func runLoop() {
        // No-op for testing
    }

    func stopRunLoop() {
        stopRunLoopCalled = true
    }

    // MARK: - Test Helpers

    func simulateInputReport(for device: MockHIDDeviceHandle, data: Data) {
        let id = ObjectIdentifier(device)
        inputCallbacksWithId[id]?(0, data)
    }

    func simulateInputReportWithId(for device: MockHIDDeviceHandle, reportId: Int, data: Data) {
        let id = ObjectIdentifier(device)
        inputCallbacksWithId[id]?(reportId, data)
    }

    func simulateDeviceRemoval(for device: MockHIDDeviceHandle) {
        let id = ObjectIdentifier(device)
        removalCallbacks[id]?()
    }

    func hasRemovalCallback(for device: MockHIDDeviceHandle) -> Bool {
        let id = ObjectIdentifier(device)
        return removalCallbacks[id] != nil
    }
}
