import Testing
import Foundation
@testable import InspectHIDCore

/// Tests for HIDDeviceService - Domain layer for HID device operations
struct HIDDeviceServiceTests {

    // MARK: - Protocol Conformance Tests

    @Test("HIDDeviceService conforms to HIDDeviceServiceProtocol")
    func serviceConformsToProtocol() {
        let mockAdapter = MockIOKitHIDAdapter(devices: [])
        let service: any HIDDeviceServiceProtocol = HIDDeviceService(adapter: mockAdapter)
        #expect(service is HIDDeviceService)
    }

    // MARK: - Device Listing Tests

    @Test("listDevices returns empty array when no devices connected")
    func listDevicesReturnsEmptyWhenNoDevices() throws {
        let mockAdapter = MockIOKitHIDAdapter(devices: [])
        let service = HIDDeviceService(adapter: mockAdapter)

        let devices = try service.listDevices()
        #expect(devices.isEmpty)
    }

    @Test("listDevices returns HIDDeviceInfo for each device")
    func listDevicesReturnsDeviceInfo() throws {
        let mockDevices = [
            MockHIDDeviceHandle(
                vendorId: 0x1234,
                productId: 0x5678,
                productName: "Device 1",
                manufacturer: "Manufacturer 1",
                serialNumber: "SN001"
            ),
            MockHIDDeviceHandle(
                vendorId: 0xABCD,
                productId: 0xEF01,
                productName: "Device 2",
                manufacturer: "Manufacturer 2",
                serialNumber: "SN002"
            )
        ]
        let mockAdapter = MockIOKitHIDAdapter(devices: mockDevices)
        let service = HIDDeviceService(adapter: mockAdapter)

        let devices = try service.listDevices()
        #expect(devices.count == 2)
    }

    @Test("listDevices assigns sequential index numbers starting from 0")
    func listDevicesAssignsSequentialIndices() throws {
        let mockDevices = [
            MockHIDDeviceHandle(vendorId: 0x1234, productId: 0x5678, productName: "Device 1", manufacturer: nil, serialNumber: nil),
            MockHIDDeviceHandle(vendorId: 0xABCD, productId: 0xEF01, productName: "Device 2", manufacturer: nil, serialNumber: nil),
            MockHIDDeviceHandle(vendorId: 0x1111, productId: 0x2222, productName: "Device 3", manufacturer: nil, serialNumber: nil)
        ]
        let mockAdapter = MockIOKitHIDAdapter(devices: mockDevices)
        let service = HIDDeviceService(adapter: mockAdapter)

        let devices = try service.listDevices()
        #expect(devices[0].index == 0)
        #expect(devices[1].index == 1)
        #expect(devices[2].index == 2)
    }

    @Test("listDevices maps vendor ID correctly")
    func listDevicesMapsVendorId() throws {
        let mockDevice = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Test",
            manufacturer: nil,
            serialNumber: nil
        )
        let mockAdapter = MockIOKitHIDAdapter(devices: [mockDevice])
        let service = HIDDeviceService(adapter: mockAdapter)

        let devices = try service.listDevices()
        #expect(devices[0].vendorId == 0x1234)
    }

    @Test("listDevices maps product ID correctly")
    func listDevicesMapsProductId() throws {
        let mockDevice = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Test",
            manufacturer: nil,
            serialNumber: nil
        )
        let mockAdapter = MockIOKitHIDAdapter(devices: [mockDevice])
        let service = HIDDeviceService(adapter: mockAdapter)

        let devices = try service.listDevices()
        #expect(devices[0].productId == 0x5678)
    }

    @Test("listDevices maps product name correctly")
    func listDevicesMapsProductName() throws {
        let mockDevice = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "My USB Device",
            manufacturer: nil,
            serialNumber: nil
        )
        let mockAdapter = MockIOKitHIDAdapter(devices: [mockDevice])
        let service = HIDDeviceService(adapter: mockAdapter)

        let devices = try service.listDevices()
        #expect(devices[0].productName == "My USB Device")
    }

    @Test("listDevices uses empty string for missing product name")
    func listDevicesHandlesMissingProductName() throws {
        let mockDevice = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: nil,
            manufacturer: nil,
            serialNumber: nil
        )
        let mockAdapter = MockIOKitHIDAdapter(devices: [mockDevice])
        let service = HIDDeviceService(adapter: mockAdapter)

        let devices = try service.listDevices()
        #expect(devices[0].productName == "")
    }

    @Test("listDevices maps manufacturer correctly")
    func listDevicesMapsManufacturer() throws {
        let mockDevice = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Device",
            manufacturer: "ACME Corp",
            serialNumber: nil
        )
        let mockAdapter = MockIOKitHIDAdapter(devices: [mockDevice])
        let service = HIDDeviceService(adapter: mockAdapter)

        let devices = try service.listDevices()
        #expect(devices[0].manufacturer == "ACME Corp")
    }

    @Test("listDevices maps serial number correctly")
    func listDevicesMapsSerialNumber() throws {
        let mockDevice = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Device",
            manufacturer: nil,
            serialNumber: "ABC123XYZ"
        )
        let mockAdapter = MockIOKitHIDAdapter(devices: [mockDevice])
        let service = HIDDeviceService(adapter: mockAdapter)

        let devices = try service.listDevices()
        #expect(devices[0].serialNumber == "ABC123XYZ")
    }
}
