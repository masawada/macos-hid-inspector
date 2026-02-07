import Foundation

/// Text output formatter for human-readable output
public enum TextFormatter {

    // MARK: - Device List Formatting

    /// Format a list of HID devices as a human-readable table
    /// - Parameter devices: Array of HIDDeviceInfo to format
    /// - Returns: Formatted string with device table
    public static func formatDeviceList(_ devices: [HIDDeviceInfo]) -> String {
        if devices.isEmpty {
            return "No HID devices found."
        }

        var lines: [String] = []

        // Header
        let indexCol = "#".padding(toLength: 5, withPad: " ", startingAt: 0)
        let vidCol = "VID".padding(toLength: 6, withPad: " ", startingAt: 0)
        let pidCol = "PID".padding(toLength: 6, withPad: " ", startingAt: 0)
        lines.append("\(indexCol)  \(vidCol)  \(pidCol)  Product Name")
        lines.append(String(repeating: "-", count: 60))

        // Device rows
        for device in devices {
            let indexStr = String(device.index).padding(toLength: 5, withPad: " ", startingAt: 0)
            let vidStr = String(format: "0x%04X", device.vendorId)
            let pidStr = String(format: "0x%04X", device.productId)
            lines.append("\(indexStr)  \(vidStr)  \(pidStr)  \(device.productName)")
        }

        return lines.joined(separator: "\n")
    }

    // MARK: - Device Descriptor Formatting

    /// Format a DeviceDescriptor as human-readable text
    /// - Parameter descriptor: DeviceDescriptor to format
    /// - Returns: Formatted string with descriptor details
    public static func formatDeviceDescriptor(_ descriptor: DeviceDescriptor) -> String {
        var lines: [String] = []

        lines.append("Device Descriptor:")
        lines.append(String(repeating: "-", count: 40))
        lines.append(formatField("bDeviceClass", value: String(format: "0x%02X (%d)", descriptor.bDeviceClass, descriptor.bDeviceClass)))
        lines.append(formatField("bDeviceSubClass", value: String(format: "0x%02X (%d)", descriptor.bDeviceSubClass, descriptor.bDeviceSubClass)))
        lines.append(formatField("bDeviceProtocol", value: String(format: "0x%02X (%d)", descriptor.bDeviceProtocol, descriptor.bDeviceProtocol)))
        lines.append(formatField("idVendor", value: String(format: "0x%04X", descriptor.idVendor)))
        lines.append(formatField("idProduct", value: String(format: "0x%04X", descriptor.idProduct)))
        lines.append(formatField("bcdDevice", value: descriptor.bcdDevice))
        lines.append(formatField("iManufacturer", value: descriptor.iManufacturer))
        lines.append(formatField("iProduct", value: descriptor.iProduct))
        lines.append(formatField("iSerialNumber", value: descriptor.iSerialNumber))

        return lines.joined(separator: "\n")
    }

    // MARK: - HID Report Formatting

    /// Format a HID Report with timestamp and hex data
    /// - Parameter report: HIDReport to format
    /// - Returns: Formatted string with timestamp and hex bytes
    public static func formatHIDReport(_ report: HIDReport) -> String {
        let timestampString = formatTimestamp(report.timestamp)
        let hexString = formatHexData(report.data)

        if report.reportId != 0 {
            return "[\(timestampString)] Report ID \(report.reportId): \(hexString)"
        } else {
            return "[\(timestampString)] \(hexString)"
        }
    }

    // MARK: - Error Formatting

    /// Format an InspectHIDError for stderr output
    /// - Parameter error: Error to format
    /// - Returns: Formatted error message
    public static func formatError(_ error: InspectHIDError) -> String {
        return "Error: \(error.errorDescription ?? "Unknown error")"
    }

    /// Format a generic error for stderr output
    /// - Parameter error: Error to format
    /// - Returns: Formatted error message
    public static func formatError(_ error: Error) -> String {
        if let hidError = error as? InspectHIDError {
            return formatError(hidError)
        }
        return "Error: \(error.localizedDescription)"
    }

    // MARK: - Private Helpers

    private static func formatField(_ name: String, value: String) -> String {
        let paddedName = name.padding(toLength: 16, withPad: " ", startingAt: 0)
        return "  \(paddedName) : \(value)"
    }

    private static func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: date)
    }

    private static func formatHexData(_ data: Data) -> String {
        if data.isEmpty {
            return "(empty)"
        }
        return data.map { String(format: "%02X", $0) }.joined(separator: " ")
    }
}
