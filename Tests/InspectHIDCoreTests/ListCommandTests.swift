import Testing
@testable import InspectHIDCore

/// Tests for ListCommand
@Suite("ListCommand Tests")
struct ListCommandTests {

    // MARK: - Device List Output Tests

    @Test("List command outputs text format with multiple devices")
    func listCommand_withDevices_outputsTextFormat() throws {
        // Given: A mock adapter with multiple devices
        let devices = [
            MockHIDDeviceHandle(
                vendorId: 0x1234,
                productId: 0x5678,
                productName: "Test Keyboard",
                manufacturer: "Test Corp",
                serialNumber: "SN123"
            ),
            MockHIDDeviceHandle(
                vendorId: 0xABCD,
                productId: 0xEF01,
                productName: "Test Mouse",
                manufacturer: "Mouse Inc",
                serialNumber: "M456"
            )
        ]
        let mockAdapter = MockIOKitHIDAdapter(devices: devices)
        let service = HIDDeviceService(adapter: mockAdapter)

        // When: Listing devices in text format
        let deviceInfos = try service.listDevices()
        let output = TextFormatter.formatDeviceList(deviceInfos)

        // Then: Output should contain device information
        #expect(output.contains("0"), "Should contain index 0")
        #expect(output.contains("1"), "Should contain index 1")
        #expect(output.contains("1234"), "Should contain VID 1234")
        #expect(output.contains("ABCD"), "Should contain VID ABCD")
        #expect(output.contains("Test Keyboard"), "Should contain first product name")
        #expect(output.contains("Test Mouse"), "Should contain second product name")
    }

    @Test("List command outputs JSON format with device data")
    func listCommand_withDevices_outputsJSONFormat() throws {
        // Given: A mock adapter with devices
        let devices = [
            MockHIDDeviceHandle(
                vendorId: 0x1234,
                productId: 0x5678,
                productName: "JSON Test Device",
                manufacturer: "JSON Corp",
                serialNumber: "JSON123"
            )
        ]
        let mockAdapter = MockIOKitHIDAdapter(devices: devices)
        let service = HIDDeviceService(adapter: mockAdapter)

        // When: Listing devices in JSON format
        let deviceInfos = try service.listDevices()
        let output = JSONFormatter.formatDeviceList(deviceInfos)

        // Then: Output should be valid JSON with device data
        #expect(output.starts(with: "["), "JSON output should start with array bracket")
        #expect(output.contains("\"index\":0"), "Should contain index")
        #expect(output.contains("\"vendorId\":\"0x1234\""), "Should contain vendorId in hex")
        #expect(output.contains("\"productId\":\"0x5678\""), "Should contain productId in hex")
        #expect(output.contains("\"productName\":\"JSON Test Device\""), "Should contain product name")
    }

    @Test("List command shows empty message when no devices")
    func listCommand_noDevices_showsEmptyMessage() throws {
        // Given: A mock adapter with no devices
        let mockAdapter = MockIOKitHIDAdapter(devices: [])
        let service = HIDDeviceService(adapter: mockAdapter)

        // When: Listing devices in text format
        let deviceInfos = try service.listDevices()
        let output = TextFormatter.formatDeviceList(deviceInfos)

        // Then: Output should indicate no devices found
        #expect(output.contains("No HID devices found"), "Should show no devices message")
    }

    @Test("List command returns empty JSON array when no devices")
    func listCommand_noDevices_JSONFormat_returnsEmptyArray() throws {
        // Given: A mock adapter with no devices
        let mockAdapter = MockIOKitHIDAdapter(devices: [])
        let service = HIDDeviceService(adapter: mockAdapter)

        // When: Listing devices in JSON format
        let deviceInfos = try service.listDevices()
        let output = JSONFormatter.formatDeviceList(deviceInfos)

        // Then: Output should be empty JSON array
        #expect(output == "[]", "Empty device list should return empty JSON array")
    }

    // MARK: - Device Info Display Tests

    @Test("List command displays index, VID, PID, and product name")
    func listCommand_displaysIndexVIDPIDProductName() throws {
        // Given: A device with specific VID/PID
        let devices = [
            MockHIDDeviceHandle(
                vendorId: 0x046D,  // Logitech VID
                productId: 0xC52B, // Unifying Receiver PID
                productName: "Logitech Unifying Receiver",
                manufacturer: "Logitech",
                serialNumber: "123456"
            )
        ]
        let mockAdapter = MockIOKitHIDAdapter(devices: devices)
        let service = HIDDeviceService(adapter: mockAdapter)

        // When: Getting device info
        let deviceInfos = try service.listDevices()

        // Then: Device info should have correct values
        #expect(deviceInfos.count == 1)
        #expect(deviceInfos[0].index == 0)
        #expect(deviceInfos[0].vendorId == 0x046D)
        #expect(deviceInfos[0].productId == 0xC52B)
        #expect(deviceInfos[0].productName == "Logitech Unifying Receiver")
    }

    // MARK: - Output Format Consistency Tests

    @Test("Text formatter uses 0x hex format for VID/PID")
    func textFormatter_deviceList_hexFormatForVIDPID() throws {
        // Given: A device
        let devices = [
            MockHIDDeviceHandle(
                vendorId: 0x1234,
                productId: 0x5678,
                productName: "Test",
                manufacturer: "Test",
                serialNumber: "SN"
            )
        ]
        let mockAdapter = MockIOKitHIDAdapter(devices: devices)
        let service = HIDDeviceService(adapter: mockAdapter)

        // When: Formatting device list
        let deviceInfos = try service.listDevices()
        let output = TextFormatter.formatDeviceList(deviceInfos)

        // Then: VID and PID should be in 0x format
        #expect(output.contains("0x1234"), "VID should be in 0x format")
        #expect(output.contains("0x5678"), "PID should be in 0x format")
    }

    @Test("JSON formatter uses hex format for VID/PID")
    func jsonFormatter_deviceList_hexFormat() throws {
        // Given: A device
        let devices = [
            MockHIDDeviceHandle(
                vendorId: 0xABCD,
                productId: 0xEF01,
                productName: "Test",
                manufacturer: "Test",
                serialNumber: "SN"
            )
        ]
        let mockAdapter = MockIOKitHIDAdapter(devices: devices)
        let service = HIDDeviceService(adapter: mockAdapter)

        // When: Formatting device list as JSON
        let deviceInfos = try service.listDevices()
        let output = JSONFormatter.formatDeviceList(deviceInfos)

        // Then: Hex values should be in hex format
        #expect(output.contains("0xabcd") || output.contains("0xABCD"), "VID should be in hex format")
        #expect(output.contains("0xef01") || output.contains("0xEF01"), "PID should be in hex format")
    }
}
