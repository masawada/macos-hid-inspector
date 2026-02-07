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

    /// JSON representation of ReportDescriptor
    private struct ReportDescriptorJSON: Codable {
        let collections: [CollectionJSON]
        let rawBytes: String
    }

    /// JSON representation of CollectionNode
    private struct CollectionJSON: Codable {
        let usagePage: String
        let usagePageName: String
        let usage: String
        let usageName: String
        let type: String
        let children: [CollectionJSON]
    }

    /// JSON representation of descriptor error
    private struct DescriptorErrorJSON: Codable {
        let error: String
        let rawBytes: String
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

    // MARK: - Report Descriptor Formatting

    /// Format a Report Descriptor as JSON
    /// - Parameters:
    ///   - collections: Collection tree from parsed descriptor
    ///   - rawBytes: Raw descriptor bytes
    ///   - usageLookup: Usage table lookup for name resolution
    /// - Returns: JSON string representation
    public static func formatReportDescriptor(
        collections: [CollectionNode],
        rawBytes: Data,
        usageLookup: UsageTableLookupProtocol
    ) -> String {
        let jsonCollections = collections.map { convertToJSON($0, usageLookup: usageLookup) }
        let jsonDescriptor = ReportDescriptorJSON(
            collections: jsonCollections,
            rawBytes: formatHexData(rawBytes)
        )
        return encodeToJSON(jsonDescriptor)
    }

    /// Format a descriptor parse error as JSON
    /// - Parameters:
    ///   - reason: Error reason description
    ///   - rawBytes: Raw descriptor bytes
    /// - Returns: JSON string representation
    public static func formatDescriptorError(reason: String, rawBytes: Data) -> String {
        let jsonError = DescriptorErrorJSON(
            error: reason,
            rawBytes: formatHexData(rawBytes)
        )
        return encodeToJSON(jsonError)
    }

    // MARK: - Private Helpers

    private static func convertToJSON(
        _ collection: CollectionNode,
        usageLookup: UsageTableLookupProtocol
    ) -> CollectionJSON {
        let pageName = usageLookup.lookupPageName(page: collection.usagePage)
        let usageName = usageLookup.lookupUsageName(
            page: collection.usagePage,
            usage: UInt16(collection.usage & 0xFFFF)
        )

        return CollectionJSON(
            usagePage: String(format: "0x%04X", collection.usagePage),
            usagePageName: pageName,
            usage: String(format: "0x%04X", collection.usage),
            usageName: usageName,
            type: collection.type.name,
            children: collection.children.map { convertToJSON($0, usageLookup: usageLookup) }
        )
    }

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
