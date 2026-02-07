import Foundation

/// JSON output formatter for machine-readable output
public enum JSONFormatter {

    // MARK: - JSON DTOs

    /// JSON representation of HIDDeviceInfo
    private struct HIDDeviceInfoJSON: Codable {
        let index: Int
        let vendorId: String
        let productId: String
        let productName: String
        let manufacturer: String
        let serialNumber: String
    }

    /// JSON representation of DeviceDescriptor
    private struct DeviceDescriptorJSON: Codable {
        let bDeviceClass: Int
        let bDeviceSubClass: Int
        let bDeviceProtocol: Int
        let idVendor: String
        let idProduct: String
        let bcdDevice: String
        let iManufacturer: String
        let iProduct: String
        let iSerialNumber: String
    }

    /// JSON representation of HIDReport
    private struct HIDReportJSON: Codable {
        let timestamp: String
        let reportId: Int
        let data: String
    }

    // MARK: - Device List Formatting

    /// Format a list of HID devices as JSON
    /// - Parameter devices: Array of HIDDeviceInfo to format
    /// - Returns: JSON string representation
    public static func formatDeviceList(_ devices: [HIDDeviceInfo]) -> String {
        let jsonDevices = devices.map { device in
            HIDDeviceInfoJSON(
                index: device.index,
                vendorId: formatHex16(device.vendorId),
                productId: formatHex16(device.productId),
                productName: device.productName,
                manufacturer: device.manufacturer,
                serialNumber: device.serialNumber
            )
        }

        return encodeToJSON(jsonDevices)
    }

    // MARK: - Device Descriptor Formatting

    /// Format a DeviceDescriptor as JSON
    /// - Parameter descriptor: DeviceDescriptor to format
    /// - Returns: JSON string representation
    public static func formatDeviceDescriptor(_ descriptor: DeviceDescriptor) -> String {
        let jsonDescriptor = DeviceDescriptorJSON(
            bDeviceClass: Int(descriptor.bDeviceClass),
            bDeviceSubClass: Int(descriptor.bDeviceSubClass),
            bDeviceProtocol: Int(descriptor.bDeviceProtocol),
            idVendor: formatHex16(descriptor.idVendor),
            idProduct: formatHex16(descriptor.idProduct),
            bcdDevice: descriptor.bcdDevice,
            iManufacturer: descriptor.iManufacturer,
            iProduct: descriptor.iProduct,
            iSerialNumber: descriptor.iSerialNumber
        )

        return encodeToJSON(jsonDescriptor)
    }

    // MARK: - HID Report Formatting

    /// Format a HID Report as JSON
    /// - Parameter report: HIDReport to format
    /// - Returns: JSON string representation
    public static func formatHIDReport(_ report: HIDReport) -> String {
        let jsonReport = HIDReportJSON(
            timestamp: formatISO8601(report.timestamp),
            reportId: report.reportId,
            data: formatHexData(report.data)
        )

        return encodeToJSON(jsonReport)
    }

    // MARK: - Private Helpers

    private static func formatHex16(_ value: UInt16) -> String {
        return String(format: "0x%04x", value)
    }

    private static func formatISO8601(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }

    private static func formatHexData(_ data: Data) -> String {
        if data.isEmpty {
            return ""
        }
        return data.map { String(format: "%02X", $0) }.joined(separator: " ")
    }

    private static func encodeToJSON<T: Encodable>(_ value: T) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]

        do {
            let data = try encoder.encode(value)
            return String(data: data, encoding: .utf8) ?? "[]"
        } catch {
            return "[]"
        }
    }
}
