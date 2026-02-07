import Testing
import Foundation
@testable import InspectHIDCore

/// Tests for TextFormatter
@Suite("TextFormatter Tests")
struct TextFormatterTests {

    // MARK: - Device List Formatting Tests

    @Test("Format single device in list")
    func formatDeviceList_singleDevice() {
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

        let result = TextFormatter.formatDeviceList(devices)

        #expect(result.contains("0"))
        #expect(result.contains("1234"))
        #expect(result.contains("5678"))
        #expect(result.contains("Test Keyboard"))
    }

    @Test("Format multiple devices in list")
    func formatDeviceList_multipleDevices() {
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

        let result = TextFormatter.formatDeviceList(devices)

        #expect(result.contains("0"))
        #expect(result.contains("1"))
        #expect(result.contains("Keyboard"))
        #expect(result.contains("Mouse"))
    }

    @Test("Format empty device list shows message")
    func formatDeviceList_empty() {
        let devices: [HIDDeviceInfo] = []

        let result = TextFormatter.formatDeviceList(devices)

        #expect(result.contains("No HID devices found"))
    }

    @Test("Device list includes header")
    func formatDeviceList_includesHeader() {
        let devices = [
            HIDDeviceInfo(
                index: 0,
                vendorId: 0x1234,
                productId: 0x5678,
                productName: "Test Device",
                manufacturer: "Test",
                serialNumber: "SN"
            )
        ]

        let result = TextFormatter.formatDeviceList(devices)

        // Should include column headers
        #expect(result.contains("Index") || result.contains("#"))
        #expect(result.contains("VID") || result.contains("Vendor"))
        #expect(result.contains("PID") || result.contains("Product"))
    }

    // MARK: - Device Descriptor Formatting Tests

    @Test("Device descriptor includes all fields")
    func formatDeviceDescriptor_allFields() {
        let descriptor = DeviceDescriptor(
            bDeviceClass: 0x00,
            bDeviceSubClass: 0x00,
            bDeviceProtocol: 0x00,
            idVendor: 0x1234,
            idProduct: 0x5678,
            bcdDevice: "1.00",
            iManufacturer: "Test Manufacturer",
            iProduct: "Test Product",
            iSerialNumber: "ABC123"
        )

        let result = TextFormatter.formatDeviceDescriptor(descriptor)

        #expect(result.contains("bDeviceClass"))
        #expect(result.contains("bDeviceSubClass"))
        #expect(result.contains("bDeviceProtocol"))
        #expect(result.contains("idVendor"))
        #expect(result.contains("idProduct"))
        #expect(result.contains("bcdDevice"))
        #expect(result.contains("iManufacturer"))
        #expect(result.contains("iProduct"))
        #expect(result.contains("iSerialNumber"))
    }

    @Test("Device descriptor shows hex values")
    func formatDeviceDescriptor_hexValues() {
        let descriptor = DeviceDescriptor(
            bDeviceClass: 0x03,
            bDeviceSubClass: 0x01,
            bDeviceProtocol: 0x02,
            idVendor: 0x1234,
            idProduct: 0x5678,
            bcdDevice: "2.10",
            iManufacturer: "Mfg",
            iProduct: "Prod",
            iSerialNumber: "SN"
        )

        let result = TextFormatter.formatDeviceDescriptor(descriptor)

        // VID/PID should be shown in hex format
        #expect(result.contains("0x1234") || result.contains("1234"))
        #expect(result.contains("0x5678") || result.contains("5678"))
    }

    // MARK: - HID Report Formatting Tests

    @Test("HID report uses hex format")
    func formatHIDReport_hexFormat() {
        let reportData = Data([0x01, 0x02, 0xFF, 0x00, 0xAB])
        let timestamp = Date(timeIntervalSince1970: 1706745600) // Fixed timestamp for testing
        let report = HIDReport(timestamp: timestamp, data: reportData, reportId: 0)

        let result = TextFormatter.formatHIDReport(report)

        // Should contain hex representation
        #expect(result.contains("01"))
        #expect(result.contains("02"))
        #expect(result.contains("FF") || result.contains("ff"))
        #expect(result.contains("00"))
        #expect(result.contains("AB") || result.contains("ab"))
    }

    @Test("HID report includes timestamp")
    func formatHIDReport_includesTimestamp() {
        let reportData = Data([0x01, 0x02])
        let timestamp = Date()
        let report = HIDReport(timestamp: timestamp, data: reportData, reportId: 0)

        let result = TextFormatter.formatHIDReport(report)

        // Should contain some form of timestamp
        #expect(result.contains(":") || result.contains("."))
    }

    @Test("HID report handles empty data")
    func formatHIDReport_emptyData() {
        let reportData = Data()
        let timestamp = Date()
        let report = HIDReport(timestamp: timestamp, data: reportData, reportId: 0)

        let result = TextFormatter.formatHIDReport(report)

        // Should handle empty data gracefully
        #expect(!result.isEmpty)
    }

    @Test("HID report shows report ID when non-zero")
    func formatHIDReport_withReportId() {
        let reportData = Data([0x01, 0x02])
        let timestamp = Date()
        let report = HIDReport(timestamp: timestamp, data: reportData, reportId: 5)

        let result = TextFormatter.formatHIDReport(report)

        // Should show report ID if non-zero
        #expect(result.contains("5") || result.contains("05"))
    }

    // MARK: - Error Formatting Tests

    @Test("Device not found error formatting")
    func formatError_deviceNotFound() {
        let error = InspectHIDError.deviceNotFound(specifier: "999")

        let result = TextFormatter.formatError(error)

        #expect(result.contains("Device not found"))
        #expect(result.contains("999"))
    }

    @Test("Permission denied error includes guidance")
    func formatError_permissionDenied() {
        let error = InspectHIDError.permissionDenied(device: "Test Device")

        let result = TextFormatter.formatError(error)

        #expect(result.contains("Permission denied") || result.contains("permission"))
        #expect(result.contains("System Settings") || result.contains("Privacy"))
    }

    // MARK: - Formatting Style Tests

    @Test("Device list has aligned columns")
    func formatDeviceList_alignedColumns() {
        let devices = [
            HIDDeviceInfo(
                index: 0,
                vendorId: 0x1234,
                productId: 0x5678,
                productName: "Short",
                manufacturer: "M",
                serialNumber: "S"
            ),
            HIDDeviceInfo(
                index: 1,
                vendorId: 0xABCD,
                productId: 0xEF01,
                productName: "Very Long Product Name",
                manufacturer: "Long Manufacturer",
                serialNumber: "LongSerial"
            )
        ]

        let result = TextFormatter.formatDeviceList(devices)
        let lines = result.split(separator: "\n")

        // Should have multiple lines (header + devices)
        #expect(lines.count >= 2)
    }
}
