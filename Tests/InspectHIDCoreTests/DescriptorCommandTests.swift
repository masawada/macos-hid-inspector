import Foundation
import Testing
@testable import InspectHIDCore

/// Tests for DescriptorCommand
@Suite("DescriptorCommand Tests")
struct DescriptorCommandTests {

    // MARK: - Text Output Tests

    @Test("Descriptor command outputs device descriptor in text format")
    func descriptorCommandTextOutput() throws {
        // Given: A mock device with descriptor info
        let mockDevice = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Test Device",
            manufacturer: "Test Manufacturer",
            serialNumber: "SN12345",
            deviceClass: 0x00,
            deviceSubClass: 0x00,
            deviceProtocol: 0x00,
            versionNumber: 0x0100
        )
        let mockAdapter = MockIOKitHIDAdapter(devices: [mockDevice])
        let service = HIDDeviceService(adapter: mockAdapter)
        let selector = DeviceSelector()

        // When: Getting descriptor by index
        let specifier = try selector.parse(input: "0")
        let descriptor = try service.getDeviceDescriptor(specifier: specifier)

        // Then: Descriptor contains expected values
        #expect(descriptor.idVendor == 0x1234)
        #expect(descriptor.idProduct == 0x5678)
        #expect(descriptor.iProduct == "Test Device")
        #expect(descriptor.iManufacturer == "Test Manufacturer")
        #expect(descriptor.iSerialNumber == "SN12345")
        #expect(descriptor.bDeviceClass == 0x00)
        #expect(descriptor.bDeviceSubClass == 0x00)
        #expect(descriptor.bDeviceProtocol == 0x00)
        #expect(descriptor.bcdDevice == "1.00")
    }

    @Test("Descriptor command formats output as text with all fields")
    func descriptorCommandTextFormatting() {
        // Given: A device descriptor
        let descriptor = DeviceDescriptor(
            bDeviceClass: 0x03,
            bDeviceSubClass: 0x01,
            bDeviceProtocol: 0x02,
            idVendor: 0xABCD,
            idProduct: 0xEF01,
            bcdDevice: "2.10",
            iManufacturer: "ACME Corp",
            iProduct: "Super Keyboard",
            iSerialNumber: "ABC123"
        )

        // When: Formatting as text
        let output = TextFormatter.formatDeviceDescriptor(descriptor)

        // Then: Output contains all required fields
        #expect(output.contains("Device Descriptor:"))
        #expect(output.contains("bDeviceClass"))
        #expect(output.contains("0x03"))
        #expect(output.contains("bDeviceSubClass"))
        #expect(output.contains("0x01"))
        #expect(output.contains("bDeviceProtocol"))
        #expect(output.contains("0x02"))
        #expect(output.contains("idVendor"))
        #expect(output.contains("0xABCD"))
        #expect(output.contains("idProduct"))
        #expect(output.contains("0xEF01"))
        #expect(output.contains("bcdDevice"))
        #expect(output.contains("2.10"))
        #expect(output.contains("iManufacturer"))
        #expect(output.contains("ACME Corp"))
        #expect(output.contains("iProduct"))
        #expect(output.contains("Super Keyboard"))
        #expect(output.contains("iSerialNumber"))
        #expect(output.contains("ABC123"))
    }

    // MARK: - JSON Output Tests

    @Test("Descriptor command formats output as JSON")
    func descriptorCommandJSONFormatting() {
        // Given: A device descriptor
        let descriptor = DeviceDescriptor(
            bDeviceClass: 0x03,
            bDeviceSubClass: 0x01,
            bDeviceProtocol: 0x02,
            idVendor: 0xABCD,
            idProduct: 0xEF01,
            bcdDevice: "2.10",
            iManufacturer: "ACME Corp",
            iProduct: "Super Keyboard",
            iSerialNumber: "ABC123"
        )

        // When: Formatting as JSON
        let output = JSONFormatter.formatDeviceDescriptor(descriptor)

        // Then: Output is valid JSON with expected content
        #expect(output.contains("\"bDeviceClass\":3"))
        #expect(output.contains("\"bDeviceSubClass\":1"))
        #expect(output.contains("\"bDeviceProtocol\":2"))
        #expect(output.contains("\"idVendor\":\"0xabcd\""))
        #expect(output.contains("\"idProduct\":\"0xef01\""))
        #expect(output.contains("\"bcdDevice\":\"2.10\""))
        #expect(output.contains("\"iManufacturer\":\"ACME Corp\""))
        #expect(output.contains("\"iProduct\":\"Super Keyboard\""))
        #expect(output.contains("\"iSerialNumber\":\"ABC123\""))
    }

    // MARK: - Error Handling Tests

    @Test("Descriptor command throws error for non-existent device index")
    func descriptorCommandDeviceNotFoundByIndex() throws {
        // Given: No devices available
        let mockAdapter = MockIOKitHIDAdapter(devices: [])
        let service = HIDDeviceService(adapter: mockAdapter)
        let selector = DeviceSelector()

        // When/Then: Requesting non-existent device throws error
        let specifier = try selector.parse(input: "0")
        #expect(throws: InspectHIDError.self) {
            _ = try service.getDeviceDescriptor(specifier: specifier)
        }
    }

    @Test("Descriptor command throws error for non-existent VID:PID")
    func descriptorCommandDeviceNotFoundByVidPid() throws {
        // Given: A device with different VID:PID
        let mockDevice = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Test Device",
            manufacturer: "Test",
            serialNumber: "123"
        )
        let mockAdapter = MockIOKitHIDAdapter(devices: [mockDevice])
        let service = HIDDeviceService(adapter: mockAdapter)
        let selector = DeviceSelector()

        // When/Then: Requesting non-matching VID:PID throws error
        let specifier = try selector.parse(input: "FFFF:FFFF")
        #expect(throws: InspectHIDError.self) {
            _ = try service.getDeviceDescriptor(specifier: specifier)
        }
    }

    @Test("Descriptor command resolves device by VID:PID")
    func descriptorCommandResolvesByVidPid() throws {
        // Given: Multiple devices
        let device1 = MockHIDDeviceHandle(
            vendorId: 0x1111,
            productId: 0x2222,
            productName: "Device 1",
            manufacturer: "Mfr1",
            serialNumber: "SN1",
            deviceClass: 0x01,
            deviceSubClass: 0x02,
            deviceProtocol: 0x03,
            versionNumber: 0x0110
        )
        let device2 = MockHIDDeviceHandle(
            vendorId: 0x3333,
            productId: 0x4444,
            productName: "Device 2",
            manufacturer: "Mfr2",
            serialNumber: "SN2",
            deviceClass: 0x04,
            deviceSubClass: 0x05,
            deviceProtocol: 0x06,
            versionNumber: 0x0200
        )
        let mockAdapter = MockIOKitHIDAdapter(devices: [device1, device2])
        let service = HIDDeviceService(adapter: mockAdapter)
        let selector = DeviceSelector()

        // When: Requesting descriptor by VID:PID
        let specifier = try selector.parse(input: "3333:4444")
        let descriptor = try service.getDeviceDescriptor(specifier: specifier)

        // Then: Correct device's descriptor is returned
        #expect(descriptor.idVendor == 0x3333)
        #expect(descriptor.idProduct == 0x4444)
        #expect(descriptor.iProduct == "Device 2")
        #expect(descriptor.bDeviceClass == 0x04)
    }

    @Test("Descriptor command throws error for invalid specifier")
    func descriptorCommandInvalidSpecifier() {
        // Given: DeviceSelector
        let selector = DeviceSelector()

        // When/Then: Parsing invalid specifier throws error
        #expect(throws: InspectHIDError.self) {
            _ = try selector.parse(input: "invalid")
        }
    }

    @Test("Descriptor command throws error for ambiguous VID:PID")
    func descriptorCommandAmbiguousDevice() throws {
        // Given: Multiple devices with same VID:PID
        let device1 = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Device 1",
            manufacturer: "Mfr",
            serialNumber: "SN1"
        )
        let device2 = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Device 2",
            manufacturer: "Mfr",
            serialNumber: "SN2"
        )
        let mockAdapter = MockIOKitHIDAdapter(devices: [device1, device2])
        let service = HIDDeviceService(adapter: mockAdapter)
        let selector = DeviceSelector()

        // When/Then: Requesting ambiguous VID:PID throws error
        let specifier = try selector.parse(input: "1234:5678")
        #expect(throws: InspectHIDError.self) {
            _ = try service.getDeviceDescriptor(specifier: specifier)
        }
    }
}
