import Testing
import Foundation
@testable import InspectHIDCore

/// Tests for JSONFormatter
@Suite("JSONFormatter Tests")
struct JSONFormatterTests {

    // MARK: - Device List JSON Tests

    @Test("Format single device as JSON")
    func formatDeviceListJSON_singleDevice() throws {
        let devices = [
            HIDDeviceInfo(
                index: 0,
                vendorId: 0x1234,
                productId: 0x5678,
                productName: "Test Keyboard",
                manufacturer: "Test Corp",
                serialNumber: "SN123"
            )
        ]

        let result = JSONFormatter.formatDeviceList(devices)

        // Should be valid JSON
        let data = result.data(using: .utf8)!
        let parsed = try #require(JSONSerialization.jsonObject(with: data) as? [[String: Any]])

        #expect(parsed.count == 1)
        let device = parsed[0]
        #expect(device["index"] as? Int == 0)
        #expect(device["vendorId"] as? String == "0x1234")
        #expect(device["productId"] as? String == "0x5678")
        #expect(device["productName"] as? String == "Test Keyboard")
        #expect(device["manufacturer"] as? String == "Test Corp")
        #expect(device["serialNumber"] as? String == "SN123")
    }

    @Test("Format multiple devices as JSON")
    func formatDeviceListJSON_multipleDevices() throws {
        let devices = [
            HIDDeviceInfo(
                index: 0,
                vendorId: 0x1234,
                productId: 0x5678,
                productName: "Keyboard",
                manufacturer: "Corp A",
                serialNumber: "SN1"
            ),
            HIDDeviceInfo(
                index: 1,
                vendorId: 0xABCD,
                productId: 0xEF01,
                productName: "Mouse",
                manufacturer: "Corp B",
                serialNumber: "SN2"
            )
        ]

        let result = JSONFormatter.formatDeviceList(devices)

        let data = result.data(using: .utf8)!
        let parsed = try #require(JSONSerialization.jsonObject(with: data) as? [[String: Any]])

        #expect(parsed.count == 2)
        #expect(parsed[0]["vendorId"] as? String == "0x1234")
        #expect(parsed[1]["vendorId"] as? String == "0xabcd")
    }

    @Test("Format empty device list as JSON")
    func formatDeviceListJSON_empty() throws {
        let devices: [HIDDeviceInfo] = []

        let result = JSONFormatter.formatDeviceList(devices)

        let data = result.data(using: .utf8)!
        let parsed = try #require(JSONSerialization.jsonObject(with: data) as? [[String: Any]])

        #expect(parsed.count == 0)
    }

    @Test("Device list JSON uses lowercase hex format")
    func formatDeviceListJSON_hexFormat() throws {
        let devices = [
            HIDDeviceInfo(
                index: 0,
                vendorId: 0x00FF,
                productId: 0x0001,
                productName: "Device",
                manufacturer: "Mfg",
                serialNumber: "SN"
            )
        ]

        let result = JSONFormatter.formatDeviceList(devices)

        let data = result.data(using: .utf8)!
        let parsed = try #require(JSONSerialization.jsonObject(with: data) as? [[String: Any]])

        // VID/PID should be 0x prefixed lowercase hex
        #expect(parsed[0]["vendorId"] as? String == "0x00ff")
        #expect(parsed[0]["productId"] as? String == "0x0001")
    }

    // MARK: - Device Descriptor JSON Tests

    @Test("Device descriptor JSON includes all fields")
    func formatDeviceDescriptorJSON_allFields() throws {
        let descriptor = DeviceDescriptor(
            bDeviceClass: 0x03,
            bDeviceSubClass: 0x01,
            bDeviceProtocol: 0x02,
            idVendor: 0x1234,
            idProduct: 0x5678,
            bcdDevice: "1.00",
            iManufacturer: "Test Manufacturer",
            iProduct: "Test Product",
            iSerialNumber: "ABC123"
        )

        let result = JSONFormatter.formatDeviceDescriptor(descriptor)

        let data = result.data(using: .utf8)!
        let parsed = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(parsed["bDeviceClass"] as? Int == 3)
        #expect(parsed["bDeviceSubClass"] as? Int == 1)
        #expect(parsed["bDeviceProtocol"] as? Int == 2)
        #expect(parsed["idVendor"] as? String == "0x1234")
        #expect(parsed["idProduct"] as? String == "0x5678")
        #expect(parsed["bcdDevice"] as? String == "1.00")
        #expect(parsed["iManufacturer"] as? String == "Test Manufacturer")
        #expect(parsed["iProduct"] as? String == "Test Product")
        #expect(parsed["iSerialNumber"] as? String == "ABC123")
    }

    @Test("Device descriptor JSON uses lowercase hex for VID/PID")
    func formatDeviceDescriptorJSON_hexVidPid() throws {
        let descriptor = DeviceDescriptor(
            bDeviceClass: 0x00,
            bDeviceSubClass: 0x00,
            bDeviceProtocol: 0x00,
            idVendor: 0xABCD,
            idProduct: 0xEF01,
            bcdDevice: "2.10",
            iManufacturer: "Mfg",
            iProduct: "Prod",
            iSerialNumber: "SN"
        )

        let result = JSONFormatter.formatDeviceDescriptor(descriptor)

        let data = result.data(using: .utf8)!
        let parsed = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(parsed["idVendor"] as? String == "0xabcd")
        #expect(parsed["idProduct"] as? String == "0xef01")
    }

    // MARK: - HID Report JSON Tests

    @Test("HID report JSON uses hex data format")
    func formatHIDReportJSON_hexData() throws {
        let reportData = Data([0x01, 0x02, 0xFF, 0x00, 0xAB])
        let timestamp = Date(timeIntervalSince1970: 1706745600)
        let report = HIDReport(timestamp: timestamp, data: reportData, reportId: 0)

        let result = JSONFormatter.formatHIDReport(report)

        let data = result.data(using: .utf8)!
        let parsed = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        // Data should be hex string with spaces
        #expect(parsed["data"] as? String == "01 02 FF 00 AB")
        #expect(parsed["reportId"] as? Int == 0)
    }

    @Test("HID report JSON uses ISO8601 timestamp")
    func formatHIDReportJSON_iso8601Timestamp() throws {
        let reportData = Data([0x01])
        let timestamp = Date(timeIntervalSince1970: 1706745600)
        let report = HIDReport(timestamp: timestamp, data: reportData, reportId: 1)

        let result = JSONFormatter.formatHIDReport(report)

        let data = result.data(using: .utf8)!
        let parsed = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        // Timestamp should be ISO8601 format
        let timestampStr = parsed["timestamp"] as? String
        #expect(timestampStr != nil)
        #expect(timestampStr!.contains("2024-02-01") || timestampStr!.contains("2024-01-31"))
    }

    @Test("HID report JSON includes report ID")
    func formatHIDReportJSON_withReportId() throws {
        let reportData = Data([0x01, 0x02])
        let timestamp = Date()
        let report = HIDReport(timestamp: timestamp, data: reportData, reportId: 5)

        let result = JSONFormatter.formatHIDReport(report)

        let data = result.data(using: .utf8)!
        let parsed = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(parsed["reportId"] as? Int == 5)
    }

    @Test("HID report JSON handles empty data")
    func formatHIDReportJSON_emptyData() throws {
        let reportData = Data()
        let timestamp = Date()
        let report = HIDReport(timestamp: timestamp, data: reportData, reportId: 0)

        let result = JSONFormatter.formatHIDReport(report)

        let data = result.data(using: .utf8)!
        let parsed = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(parsed["data"] as? String == "")
    }

    // MARK: - Valid JSON Structure Tests

    @Test("Device list is valid JSON array")
    func deviceListJSON_isValidJSONArray() throws {
        let devices = [
            HIDDeviceInfo(
                index: 0,
                vendorId: 0x1234,
                productId: 0x5678,
                productName: "Test",
                manufacturer: "M",
                serialNumber: "S"
            )
        ]

        let result = JSONFormatter.formatDeviceList(devices)

        // Should start with [ and end with ]
        #expect(result.hasPrefix("["))
        #expect(result.hasSuffix("]"))
    }

    @Test("Device descriptor is valid JSON object")
    func deviceDescriptorJSON_isValidJSONObject() throws {
        let descriptor = DeviceDescriptor(
            bDeviceClass: 0x00,
            bDeviceSubClass: 0x00,
            bDeviceProtocol: 0x00,
            idVendor: 0x1234,
            idProduct: 0x5678,
            bcdDevice: "1.00",
            iManufacturer: "M",
            iProduct: "P",
            iSerialNumber: "S"
        )

        let result = JSONFormatter.formatDeviceDescriptor(descriptor)

        // Should start with { and end with }
        #expect(result.hasPrefix("{"))
        #expect(result.hasSuffix("}"))
    }

    @Test("HID report is valid JSON object")
    func hidReportJSON_isValidJSONObject() throws {
        let report = HIDReport(timestamp: Date(), data: Data([0x01]), reportId: 0)

        let result = JSONFormatter.formatHIDReport(report)

        // Should start with { and end with }
        #expect(result.hasPrefix("{"))
        #expect(result.hasSuffix("}"))
    }
}
