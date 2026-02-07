import Foundation
import Testing
import ArgumentParser
@testable import InspectHIDCore

/// Tests for exclusive/non-exclusive device open mode
/// Feature: Allow users to choose between exclusive and non-exclusive device access
@Suite("Exclusive Mode Tests")
struct ExclusiveModeTests {

    // MARK: - MonitorCommand Option Tests

    @Suite("MonitorCommand --exclusive Option")
    struct MonitorCommandExclusiveOption {

        @Test("MonitorCommand accepts --exclusive flag")
        func acceptsExclusiveFlag() throws {
            let command = try MonitorCommand.parse(["0", "--exclusive"])
            #expect(command.exclusive == true)
        }

        @Test("MonitorCommand accepts --no-exclusive flag for non-exclusive mode")
        func acceptsNoExclusiveFlag() throws {
            let command = try MonitorCommand.parse(["0", "--no-exclusive"])
            #expect(command.exclusive == false)
        }

        @Test("MonitorCommand defaults to exclusive mode")
        func defaultsToExclusive() throws {
            let command = try MonitorCommand.parse(["0"])
            #expect(command.exclusive == true, "Should default to exclusive mode for reliable report capture")
        }

        @Test("MonitorCommand --exclusive works with --json")
        func exclusiveWorksWithJson() throws {
            let command = try MonitorCommand.parse(["0", "--exclusive", "--json"])
            #expect(command.exclusive == true)
            #expect(command.json == true)
        }

        @Test("MonitorCommand --no-exclusive works with --json")
        func noExclusiveWorksWithJson() throws {
            let command = try MonitorCommand.parse(["0", "--no-exclusive", "--json"])
            #expect(command.exclusive == false)
            #expect(command.json == true)
        }
    }

    // MARK: - IOKitHIDAdapter Open Mode Tests

    @Suite("IOKitHIDAdapter Open Mode")
    struct IOKitHIDAdapterOpenMode {

        @Test("MockIOKitHIDAdapter tracks exclusive mode on open")
        func mockAdapterTracksExclusiveMode() throws {
            let device = MockHIDDeviceHandle(
                vendorId: 0x1234,
                productId: 0x5678,
                productName: "Test Device",
                manufacturer: "Test",
                serialNumber: nil
            )
            let adapter = MockIOKitHIDAdapterWithExclusiveTracking(devices: [device])

            try adapter.open(device, exclusive: true)
            #expect(adapter.lastOpenWasExclusive == true)

            adapter.close(device)

            try adapter.open(device, exclusive: false)
            #expect(adapter.lastOpenWasExclusive == false)
        }
    }

    // MARK: - HIDDeviceService Exclusive Mode Tests

    @Suite("HIDDeviceService Exclusive Mode")
    struct HIDDeviceServiceExclusiveMode {

        @Test("startMonitoring passes exclusive flag to adapter")
        func startMonitoringPassesExclusiveFlag() throws {
            let device = MockHIDDeviceHandle(
                vendorId: 0x1234,
                productId: 0x5678,
                productName: "Test Device",
                manufacturer: "Test",
                serialNumber: nil
            )
            let adapter = MockIOKitHIDAdapterWithExclusiveTracking(devices: [device])
            let service = HIDDeviceService(adapter: adapter)

            try service.startMonitoring(
                specifier: .index(0),
                exclusive: true,
                onReport: { _ in },
                onDisconnect: {}
            )

            #expect(adapter.lastOpenWasExclusive == true)
        }

        @Test("startMonitoring with non-exclusive mode")
        func startMonitoringNonExclusive() throws {
            let device = MockHIDDeviceHandle(
                vendorId: 0x1234,
                productId: 0x5678,
                productName: "Test Device",
                manufacturer: "Test",
                serialNumber: nil
            )
            let adapter = MockIOKitHIDAdapterWithExclusiveTracking(devices: [device])
            let service = HIDDeviceService(adapter: adapter)

            try service.startMonitoring(
                specifier: .index(0),
                exclusive: false,
                onReport: { _ in },
                onDisconnect: {}
            )

            #expect(adapter.lastOpenWasExclusive == false)
        }

        @Test("startMonitoring defaults to exclusive when not specified")
        func startMonitoringDefaultsToExclusive() throws {
            let device = MockHIDDeviceHandle(
                vendorId: 0x1234,
                productId: 0x5678,
                productName: "Test Device",
                manufacturer: "Test",
                serialNumber: nil
            )
            let adapter = MockIOKitHIDAdapterWithExclusiveTracking(devices: [device])
            let service = HIDDeviceService(adapter: adapter)

            // Use the backwards-compatible overload without exclusive parameter
            try service.startMonitoring(
                specifier: .index(0),
                onReport: { _ in },
                onDisconnect: {}
            )

            #expect(adapter.lastOpenWasExclusive == true, "Should default to exclusive for backwards compatibility")
        }
    }
}

// MARK: - Mock Adapter with Exclusive Tracking

/// Mock adapter that tracks whether open was called with exclusive mode
final class MockIOKitHIDAdapterWithExclusiveTracking: IOKitHIDAdapterProtocol, @unchecked Sendable {
    private let devices: [MockHIDDeviceHandle]
    private(set) var openedDevices: [MockHIDDeviceHandle] = []
    private(set) var lastOpenWasExclusive: Bool?
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
        (device as? MockHIDDeviceHandle)?.vendorId
    }

    func getProductId(_ device: any HIDDeviceHandle) -> UInt16? {
        (device as? MockHIDDeviceHandle)?.productId
    }

    func getProductName(_ device: any HIDDeviceHandle) -> String? {
        (device as? MockHIDDeviceHandle)?.productName
    }

    func getManufacturer(_ device: any HIDDeviceHandle) -> String? {
        (device as? MockHIDDeviceHandle)?.manufacturer
    }

    func getSerialNumber(_ device: any HIDDeviceHandle) -> String? {
        (device as? MockHIDDeviceHandle)?.serialNumber
    }

    func getDeviceClass(_ device: any HIDDeviceHandle) -> UInt8? { nil }
    func getDeviceSubClass(_ device: any HIDDeviceHandle) -> UInt8? { nil }
    func getDeviceProtocol(_ device: any HIDDeviceHandle) -> UInt8? { nil }
    func getVersionNumber(_ device: any HIDDeviceHandle) -> UInt16? { nil }
    func getReportDescriptor(_ device: any HIDDeviceHandle) -> Data? { nil }

    // Old open method - for backwards compatibility testing
    func open(_ device: any HIDDeviceHandle) throws {
        try open(device, exclusive: true)
    }

    // New open method with exclusive parameter
    func open(_ device: any HIDDeviceHandle, exclusive: Bool) throws {
        guard let mock = device as? MockHIDDeviceHandle else {
            throw InspectHIDError.ioKitError(code: -1)
        }
        openedDevices.append(mock)
        lastOpenWasExclusive = exclusive
    }

    func close(_ device: any HIDDeviceHandle) {
        guard let mock = device as? MockHIDDeviceHandle else { return }
        openedDevices.removeAll { $0 === mock }
    }

    func registerInputReportCallbackWithId(_ device: any HIDDeviceHandle, callback: @escaping (Int, Data) -> Void) {
        guard let mock = device as? MockHIDDeviceHandle else { return }
        inputCallbacksWithId[ObjectIdentifier(mock)] = callback
    }

    func registerRemovalCallback(_ device: any HIDDeviceHandle, callback: @escaping () -> Void) {
        guard let mock = device as? MockHIDDeviceHandle else { return }
        removalCallbacks[ObjectIdentifier(mock)] = callback
    }

    func runLoop() {}
    func stopRunLoop() { stopRunLoopCalled = true }
}
