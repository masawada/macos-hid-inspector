import Testing
@testable import InspectHIDCore

/// Tests for DeviceSelector - device specifier parsing and resolution
struct DeviceSelectorTests {

    // MARK: - Index Format Tests

    @Test("Parse index format - single digit")
    func parseIndexFormatSingleDigit() throws {
        let selector = DeviceSelector()
        let result = try selector.parse(input: "0")
        #expect(result == .index(0))
    }

    @Test("Parse index format - multi digit")
    func parseIndexFormatMultiDigit() throws {
        let selector = DeviceSelector()
        let result = try selector.parse(input: "123")
        #expect(result == .index(123))
    }

    @Test("Parse index format - with leading zeros")
    func parseIndexFormatWithLeadingZeros() throws {
        let selector = DeviceSelector()
        let result = try selector.parse(input: "007")
        #expect(result == .index(7))
    }

    // MARK: - VID:PID Format Tests

    @Test("Parse VID:PID format - lowercase hex")
    func parseVidPidFormatLowercaseHex() throws {
        let selector = DeviceSelector()
        let result = try selector.parse(input: "1234:5678")
        #expect(result == .vidPid(vendorId: 0x1234, productId: 0x5678))
    }

    @Test("Parse VID:PID format - uppercase hex")
    func parseVidPidFormatUppercaseHex() throws {
        let selector = DeviceSelector()
        let result = try selector.parse(input: "ABCD:EF01")
        #expect(result == .vidPid(vendorId: 0xABCD, productId: 0xEF01))
    }

    @Test("Parse VID:PID format - mixed case hex")
    func parseVidPidFormatMixedCaseHex() throws {
        let selector = DeviceSelector()
        let result = try selector.parse(input: "AbCd:1234")
        #expect(result == .vidPid(vendorId: 0xABCD, productId: 0x1234))
    }

    @Test("Parse VID:PID format - with 0x prefix")
    func parseVidPidFormatWithPrefix() throws {
        let selector = DeviceSelector()
        let result = try selector.parse(input: "0x1234:0x5678")
        #expect(result == .vidPid(vendorId: 0x1234, productId: 0x5678))
    }

    @Test("Parse VID:PID format - short values")
    func parseVidPidFormatShortValues() throws {
        let selector = DeviceSelector()
        let result = try selector.parse(input: "1:2")
        #expect(result == .vidPid(vendorId: 0x1, productId: 0x2))
    }

    @Test("Parse VID:PID format - max values")
    func parseVidPidFormatMaxValues() throws {
        let selector = DeviceSelector()
        let result = try selector.parse(input: "FFFF:FFFF")
        #expect(result == .vidPid(vendorId: 0xFFFF, productId: 0xFFFF))
    }

    // MARK: - Parse Error Cases

    @Test("Parse invalid format - empty string")
    func parseInvalidFormatEmptyString() {
        let selector = DeviceSelector()
        #expect(throws: InspectHIDError.self) {
            _ = try selector.parse(input: "")
        }
    }

    @Test("Parse invalid format - non-hex characters")
    func parseInvalidFormatNonHexCharacters() {
        let selector = DeviceSelector()
        #expect(throws: InspectHIDError.self) {
            _ = try selector.parse(input: "GHIJ:1234")
        }
    }

    @Test("Parse invalid format - missing PID")
    func parseInvalidFormatMissingPid() {
        let selector = DeviceSelector()
        #expect(throws: InspectHIDError.self) {
            _ = try selector.parse(input: "1234:")
        }
    }

    @Test("Parse invalid format - missing VID")
    func parseInvalidFormatMissingVid() {
        let selector = DeviceSelector()
        #expect(throws: InspectHIDError.self) {
            _ = try selector.parse(input: ":5678")
        }
    }

    @Test("Parse invalid format - negative index")
    func parseInvalidFormatNegativeIndex() {
        let selector = DeviceSelector()
        #expect(throws: InspectHIDError.self) {
            _ = try selector.parse(input: "-1")
        }
    }

    @Test("Parse invalid format - overflow VID")
    func parseInvalidFormatOverflowVid() {
        let selector = DeviceSelector()
        #expect(throws: InspectHIDError.self) {
            _ = try selector.parse(input: "10000:1234")
        }
    }

    @Test("Parse invalid format - overflow PID")
    func parseInvalidFormatOverflowPid() {
        let selector = DeviceSelector()
        #expect(throws: InspectHIDError.self) {
            _ = try selector.parse(input: "1234:10000")
        }
    }

    @Test("Parse invalid format - random text")
    func parseInvalidFormatRandomText() {
        let selector = DeviceSelector()
        #expect(throws: InspectHIDError.self) {
            _ = try selector.parse(input: "keyboard")
        }
    }

    @Test("Parse invalid format - multiple colons")
    func parseInvalidFormatMultipleColons() {
        let selector = DeviceSelector()
        #expect(throws: InspectHIDError.self) {
            _ = try selector.parse(input: "1234:5678:9ABC")
        }
    }

    // MARK: - Resolve by Index Tests

    @Test("Resolve by index - valid index")
    func resolveByIndexValidIndex() throws {
        let selector = DeviceSelector()
        let devices = createTestDevices()
        let result = try selector.resolve(specifier: .index(1), from: devices)
        #expect(result.index == 1)
        #expect(result.vendorId == 0x2222)
    }

    @Test("Resolve by index - first device")
    func resolveByIndexFirstDevice() throws {
        let selector = DeviceSelector()
        let devices = createTestDevices()
        let result = try selector.resolve(specifier: .index(0), from: devices)
        #expect(result.index == 0)
        #expect(result.vendorId == 0x1111)
    }

    @Test("Resolve by index - last device")
    func resolveByIndexLastDevice() throws {
        let selector = DeviceSelector()
        let devices = createTestDevices()
        let result = try selector.resolve(specifier: .index(2), from: devices)
        #expect(result.index == 2)
        #expect(result.vendorId == 0x3333)
    }

    @Test("Resolve by index - out of bounds")
    func resolveByIndexOutOfBounds() throws {
        let selector = DeviceSelector()
        let devices = createTestDevices()
        #expect {
            _ = try selector.resolve(specifier: .index(10), from: devices)
        } throws: { error in
            guard let hidError = error as? InspectHIDError,
                  case .deviceNotFound(let specifier) = hidError else {
                return false
            }
            return specifier == "index 10"
        }
    }

    @Test("Resolve by index - empty device list")
    func resolveByIndexEmptyDeviceList() {
        let selector = DeviceSelector()
        #expect(throws: InspectHIDError.self) {
            _ = try selector.resolve(specifier: .index(0), from: [])
        }
    }

    // MARK: - Resolve by VID:PID Tests

    @Test("Resolve by VID:PID - single match")
    func resolveByVidPidSingleMatch() throws {
        let selector = DeviceSelector()
        let devices = createTestDevices()
        let result = try selector.resolve(specifier: .vidPid(vendorId: 0x2222, productId: 0xBBBB), from: devices)
        #expect(result.index == 1)
        #expect(result.productName == "Device B")
    }

    @Test("Resolve by VID:PID - no match")
    func resolveByVidPidNoMatch() throws {
        let selector = DeviceSelector()
        let devices = createTestDevices()
        #expect {
            _ = try selector.resolve(specifier: .vidPid(vendorId: 0x9999, productId: 0x9999), from: devices)
        } throws: { error in
            guard let hidError = error as? InspectHIDError,
                  case .deviceNotFound(let specifier) = hidError else {
                return false
            }
            return specifier == "9999:9999"
        }
    }

    @Test("Resolve by VID:PID - multiple matches")
    func resolveByVidPidMultipleMatches() throws {
        let selector = DeviceSelector()
        let devices = createTestDevicesWithDuplicateVidPid()
        #expect {
            _ = try selector.resolve(specifier: .vidPid(vendorId: 0x1111, productId: 0xAAAA), from: devices)
        } throws: { error in
            guard let hidError = error as? InspectHIDError,
                  case .ambiguousDevice(let count) = hidError else {
                return false
            }
            return count == 2
        }
    }

    @Test("Resolve by VID:PID - empty device list")
    func resolveByVidPidEmptyDeviceList() {
        let selector = DeviceSelector()
        #expect(throws: InspectHIDError.self) {
            _ = try selector.resolve(specifier: .vidPid(vendorId: 0x1234, productId: 0x5678), from: [])
        }
    }

    // MARK: - Helper Methods

    private func createTestDevices() -> [HIDDeviceInfo] {
        return [
            HIDDeviceInfo(index: 0, vendorId: 0x1111, productId: 0xAAAA, productName: "Device A", manufacturer: "Maker A", serialNumber: "SN-001"),
            HIDDeviceInfo(index: 1, vendorId: 0x2222, productId: 0xBBBB, productName: "Device B", manufacturer: "Maker B", serialNumber: "SN-002"),
            HIDDeviceInfo(index: 2, vendorId: 0x3333, productId: 0xCCCC, productName: "Device C", manufacturer: "Maker C", serialNumber: "SN-003"),
        ]
    }

    private func createTestDevicesWithDuplicateVidPid() -> [HIDDeviceInfo] {
        return [
            HIDDeviceInfo(index: 0, vendorId: 0x1111, productId: 0xAAAA, productName: "Device A1", manufacturer: "Maker A", serialNumber: "SN-001"),
            HIDDeviceInfo(index: 1, vendorId: 0x1111, productId: 0xAAAA, productName: "Device A2", manufacturer: "Maker A", serialNumber: "SN-002"),
            HIDDeviceInfo(index: 2, vendorId: 0x2222, productId: 0xBBBB, productName: "Device B", manufacturer: "Maker B", serialNumber: "SN-003"),
        ]
    }
}
