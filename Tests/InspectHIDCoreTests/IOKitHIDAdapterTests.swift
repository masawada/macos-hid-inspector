import Testing
import Foundation
@testable import InspectHIDCore

/// Tests for IOKitHIDAdapter - Infrastructure layer for HID device access
struct IOKitHIDAdapterTests {

    // MARK: - Protocol Conformance Tests

    @Test("IOKitHIDAdapter conforms to IOKitHIDAdapterProtocol")
    func adapterConformsToProtocol() {
        let adapter: any IOKitHIDAdapterProtocol = IOKitHIDAdapter()
        #expect(adapter is IOKitHIDAdapter)
    }

    // MARK: - Device Enumeration Tests

    @Test("enumerateDevices returns devices or throws permission error")
    func enumerateDevicesReturnsArrayOrThrowsPermissionError() throws {
        let adapter = IOKitHIDAdapter()
        // In CI/testing environments, IOHIDManager may fail with permission errors
        // This is expected behavior - the adapter should properly throw InspectHIDError
        do {
            let devices = try adapter.enumerateDevices()
            // If we get here, we have permission and should get an array
            #expect(devices is [any HIDDeviceHandle])
        } catch let error as InspectHIDError {
            // Permission error is expected in sandboxed/restricted environments
            // Verify the error is properly mapped to InspectHIDError
            switch error {
            case .permissionDenied, .ioKitError:
                // These are acceptable errors in restricted environments
                break
            default:
                Issue.record("Unexpected error type: \(error)")
            }
        }
    }

    @Test("enumerateDevices handles no devices gracefully")
    func enumerateDevicesHandlesEmpty() throws {
        // MockAdapter for testing empty case
        let adapter = MockIOKitHIDAdapter(devices: [])
        let devices = try adapter.enumerateDevices()
        #expect(devices.isEmpty)
    }

    // MARK: - Property Extraction Tests

    @Test("getVendorId extracts vendor ID from device")
    func getVendorIdFromDevice() throws {
        let mockDevice = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Test Device",
            manufacturer: "Test Manufacturer",
            serialNumber: "SN123"
        )
        let adapter = MockIOKitHIDAdapter(devices: [mockDevice])

        let vendorId = adapter.getVendorId(mockDevice)
        #expect(vendorId == 0x1234)
    }

    @Test("getProductId extracts product ID from device")
    func getProductIdFromDevice() throws {
        let mockDevice = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Test Device",
            manufacturer: "Test Manufacturer",
            serialNumber: "SN123"
        )
        let adapter = MockIOKitHIDAdapter(devices: [mockDevice])

        let productId = adapter.getProductId(mockDevice)
        #expect(productId == 0x5678)
    }

    @Test("getProductName extracts product name from device")
    func getProductNameFromDevice() throws {
        let mockDevice = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Test Device",
            manufacturer: "Test Manufacturer",
            serialNumber: "SN123"
        )
        let adapter = MockIOKitHIDAdapter(devices: [mockDevice])

        let productName = adapter.getProductName(mockDevice)
        #expect(productName == "Test Device")
    }

    @Test("getManufacturer extracts manufacturer from device")
    func getManufacturerFromDevice() throws {
        let mockDevice = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Test Device",
            manufacturer: "Test Manufacturer",
            serialNumber: "SN123"
        )
        let adapter = MockIOKitHIDAdapter(devices: [mockDevice])

        let manufacturer = adapter.getManufacturer(mockDevice)
        #expect(manufacturer == "Test Manufacturer")
    }

    @Test("getSerialNumber extracts serial number from device")
    func getSerialNumberFromDevice() throws {
        let mockDevice = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Test Device",
            manufacturer: "Test Manufacturer",
            serialNumber: "SN123"
        )
        let adapter = MockIOKitHIDAdapter(devices: [mockDevice])

        let serialNumber = adapter.getSerialNumber(mockDevice)
        #expect(serialNumber == "SN123")
    }

    @Test("Missing properties return nil or empty string")
    func missingPropertiesReturnDefaults() throws {
        let mockDevice = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: nil,
            manufacturer: nil,
            serialNumber: nil
        )
        let adapter = MockIOKitHIDAdapter(devices: [mockDevice])

        #expect(adapter.getProductName(mockDevice) == nil)
        #expect(adapter.getManufacturer(mockDevice) == nil)
        #expect(adapter.getSerialNumber(mockDevice) == nil)
    }
}
