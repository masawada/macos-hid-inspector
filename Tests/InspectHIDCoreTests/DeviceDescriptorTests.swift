import Testing
import Foundation
@testable import InspectHIDCore

/// Tests for Device Descriptor functionality
struct DeviceDescriptorTests {

    // MARK: - DeviceDescriptor Model Tests

    @Test("DeviceDescriptor stores all USB descriptor fields")
    func deviceDescriptorStoresAllFields() {
        let descriptor = DeviceDescriptor(
            bDeviceClass: 0x00,
            bDeviceSubClass: 0x00,
            bDeviceProtocol: 0x00,
            idVendor: 0x1234,
            idProduct: 0x5678,
            bcdDevice: "1.00",
            iManufacturer: "Test Manufacturer",
            iProduct: "Test Product",
            iSerialNumber: "SN12345"
        )

        #expect(descriptor.bDeviceClass == 0x00)
        #expect(descriptor.bDeviceSubClass == 0x00)
        #expect(descriptor.bDeviceProtocol == 0x00)
        #expect(descriptor.idVendor == 0x1234)
        #expect(descriptor.idProduct == 0x5678)
        #expect(descriptor.bcdDevice == "1.00")
        #expect(descriptor.iManufacturer == "Test Manufacturer")
        #expect(descriptor.iProduct == "Test Product")
        #expect(descriptor.iSerialNumber == "SN12345")
    }

    @Test("DeviceDescriptor is Codable for JSON output")
    func deviceDescriptorIsCodable() throws {
        let descriptor = DeviceDescriptor(
            bDeviceClass: 0x03,
            bDeviceSubClass: 0x01,
            bDeviceProtocol: 0x02,
            idVendor: 0x1234,
            idProduct: 0x5678,
            bcdDevice: "2.00",
            iManufacturer: "ACME",
            iProduct: "Widget",
            iSerialNumber: "ABC123"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(descriptor)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DeviceDescriptor.self, from: data)

        #expect(decoded == descriptor)
    }

    // MARK: - IOKitHIDAdapter Descriptor Property Tests

    @Test("IOKitHIDAdapter can get bDeviceClass from device")
    func adapterGetsBDeviceClass() {
        let mockDevice = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Device",
            manufacturer: nil,
            serialNumber: nil,
            deviceClass: 0x03,
            deviceSubClass: 0x01,
            deviceProtocol: 0x02,
            versionNumber: 0x0100,
            reportDescriptor: nil
        )
        let adapter = MockIOKitHIDAdapter(devices: [mockDevice])

        let deviceClass = adapter.getDeviceClass(mockDevice)
        #expect(deviceClass == 0x03)
    }

    @Test("IOKitHIDAdapter can get bDeviceSubClass from device")
    func adapterGetsBDeviceSubClass() {
        let mockDevice = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Device",
            manufacturer: nil,
            serialNumber: nil,
            deviceClass: 0x03,
            deviceSubClass: 0x01,
            deviceProtocol: 0x02,
            versionNumber: 0x0100,
            reportDescriptor: nil
        )
        let adapter = MockIOKitHIDAdapter(devices: [mockDevice])

        let subClass = adapter.getDeviceSubClass(mockDevice)
        #expect(subClass == 0x01)
    }

    @Test("IOKitHIDAdapter can get bDeviceProtocol from device")
    func adapterGetsBDeviceProtocol() {
        let mockDevice = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Device",
            manufacturer: nil,
            serialNumber: nil,
            deviceClass: 0x03,
            deviceSubClass: 0x01,
            deviceProtocol: 0x02,
            versionNumber: 0x0100,
            reportDescriptor: nil
        )
        let adapter = MockIOKitHIDAdapter(devices: [mockDevice])

        let deviceProtocol = adapter.getDeviceProtocol(mockDevice)
        #expect(deviceProtocol == 0x02)
    }

    @Test("IOKitHIDAdapter can get version number (bcdDevice) from device")
    func adapterGetsVersionNumber() {
        let mockDevice = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Device",
            manufacturer: nil,
            serialNumber: nil,
            deviceClass: 0x03,
            deviceSubClass: 0x01,
            deviceProtocol: 0x02,
            versionNumber: 0x0210,
            reportDescriptor: nil
        )
        let adapter = MockIOKitHIDAdapter(devices: [mockDevice])

        let version = adapter.getVersionNumber(mockDevice)
        #expect(version == 0x0210)
    }

    @Test("IOKitHIDAdapter can get report descriptor data from device")
    func adapterGetsReportDescriptor() {
        let reportData = Data([0x05, 0x01, 0x09, 0x06, 0xA1, 0x01])
        let mockDevice = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Device",
            manufacturer: nil,
            serialNumber: nil,
            deviceClass: 0x03,
            deviceSubClass: 0x01,
            deviceProtocol: 0x02,
            versionNumber: 0x0100,
            reportDescriptor: reportData
        )
        let adapter = MockIOKitHIDAdapter(devices: [mockDevice])

        let descriptor = adapter.getReportDescriptor(mockDevice)
        #expect(descriptor == reportData)
    }

    @Test("IOKitHIDAdapter returns nil for missing report descriptor")
    func adapterReturnsNilForMissingReportDescriptor() {
        let mockDevice = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Device",
            manufacturer: nil,
            serialNumber: nil,
            deviceClass: 0x03,
            deviceSubClass: 0x01,
            deviceProtocol: 0x02,
            versionNumber: 0x0100,
            reportDescriptor: nil
        )
        let adapter = MockIOKitHIDAdapter(devices: [mockDevice])

        let descriptor = adapter.getReportDescriptor(mockDevice)
        #expect(descriptor == nil)
    }

    // MARK: - HIDDeviceService Descriptor Tests

    @Test("HIDDeviceService can get device descriptor by specifier")
    func serviceGetsDeviceDescriptor() throws {
        let mockDevice = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Test Product",
            manufacturer: "Test Manufacturer",
            serialNumber: "SN123",
            deviceClass: 0x00,
            deviceSubClass: 0x00,
            deviceProtocol: 0x00,
            versionNumber: 0x0100,
            reportDescriptor: nil
        )
        let adapter = MockIOKitHIDAdapter(devices: [mockDevice])
        let service = HIDDeviceService(adapter: adapter)

        let descriptor = try service.getDeviceDescriptor(specifier: .index(0))

        #expect(descriptor.idVendor == 0x1234)
        #expect(descriptor.idProduct == 0x5678)
        #expect(descriptor.iProduct == "Test Product")
        #expect(descriptor.iManufacturer == "Test Manufacturer")
        #expect(descriptor.iSerialNumber == "SN123")
    }

    @Test("HIDDeviceService formats bcdDevice as version string")
    func serviceFormatsBcdDevice() throws {
        let mockDevice = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: nil,
            manufacturer: nil,
            serialNumber: nil,
            deviceClass: 0x00,
            deviceSubClass: 0x00,
            deviceProtocol: 0x00,
            versionNumber: 0x0210,  // 2.10
            reportDescriptor: nil
        )
        let adapter = MockIOKitHIDAdapter(devices: [mockDevice])
        let service = HIDDeviceService(adapter: adapter)

        let descriptor = try service.getDeviceDescriptor(specifier: .index(0))

        #expect(descriptor.bcdDevice == "2.10")
    }

    @Test("HIDDeviceService can get device descriptor by VID:PID")
    func serviceGetsDescriptorByVidPid() throws {
        let mockDevices = [
            MockHIDDeviceHandle(
                vendorId: 0x1111,
                productId: 0x2222,
                productName: "Device 1",
                manufacturer: nil,
                serialNumber: nil,
                deviceClass: 0x00,
                deviceSubClass: 0x00,
                deviceProtocol: 0x00,
                versionNumber: 0x0100,
                reportDescriptor: nil
            ),
            MockHIDDeviceHandle(
                vendorId: 0x1234,
                productId: 0x5678,
                productName: "Device 2",
                manufacturer: nil,
                serialNumber: nil,
                deviceClass: 0x03,
                deviceSubClass: 0x01,
                deviceProtocol: 0x02,
                versionNumber: 0x0200,
                reportDescriptor: nil
            )
        ]
        let adapter = MockIOKitHIDAdapter(devices: mockDevices)
        let service = HIDDeviceService(adapter: adapter)

        let descriptor = try service.getDeviceDescriptor(specifier: .vidPid(vendorId: 0x1234, productId: 0x5678))

        #expect(descriptor.idVendor == 0x1234)
        #expect(descriptor.idProduct == 0x5678)
        #expect(descriptor.bDeviceClass == 0x03)
    }

    @Test("HIDDeviceService throws error when device not found by index")
    func serviceThrowsErrorForInvalidIndex() throws {
        let mockDevice = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Device",
            manufacturer: nil,
            serialNumber: nil,
            deviceClass: 0x00,
            deviceSubClass: 0x00,
            deviceProtocol: 0x00,
            versionNumber: 0x0100,
            reportDescriptor: nil
        )
        let adapter = MockIOKitHIDAdapter(devices: [mockDevice])
        let service = HIDDeviceService(adapter: adapter)

        #expect(throws: InspectHIDError.self) {
            _ = try service.getDeviceDescriptor(specifier: .index(5))
        }
    }

    @Test("HIDDeviceService throws error when device not found by VID:PID")
    func serviceThrowsErrorForInvalidVidPid() throws {
        let mockDevice = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Device",
            manufacturer: nil,
            serialNumber: nil,
            deviceClass: 0x00,
            deviceSubClass: 0x00,
            deviceProtocol: 0x00,
            versionNumber: 0x0100,
            reportDescriptor: nil
        )
        let adapter = MockIOKitHIDAdapter(devices: [mockDevice])
        let service = HIDDeviceService(adapter: adapter)

        #expect(throws: InspectHIDError.self) {
            _ = try service.getDeviceDescriptor(specifier: .vidPid(vendorId: 0xFFFF, productId: 0xFFFF))
        }
    }

    // MARK: - Report Descriptor Tests

    @Test("HIDDeviceService can get report descriptor")
    func serviceGetsReportDescriptor() throws {
        let reportData = Data([0x05, 0x01, 0x09, 0x06, 0xA1, 0x01])
        let mockDevice = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Device",
            manufacturer: nil,
            serialNumber: nil,
            deviceClass: 0x03,
            deviceSubClass: 0x01,
            deviceProtocol: 0x01,
            versionNumber: 0x0100,
            reportDescriptor: reportData
        )
        let adapter = MockIOKitHIDAdapter(devices: [mockDevice])
        let service = HIDDeviceService(adapter: adapter)

        let descriptor = try service.getReportDescriptor(specifier: .index(0))

        #expect(descriptor == reportData)
    }

    @Test("HIDDeviceService throws error when report descriptor not available")
    func serviceThrowsErrorForMissingReportDescriptor() throws {
        let mockDevice = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Device",
            manufacturer: nil,
            serialNumber: nil,
            deviceClass: 0x03,
            deviceSubClass: 0x01,
            deviceProtocol: 0x01,
            versionNumber: 0x0100,
            reportDescriptor: nil
        )
        let adapter = MockIOKitHIDAdapter(devices: [mockDevice])
        let service = HIDDeviceService(adapter: adapter)

        #expect(throws: InspectHIDError.self) {
            _ = try service.getReportDescriptor(specifier: .index(0))
        }
    }
}
