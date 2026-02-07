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

    // MARK: - Report Descriptor Formatting

    /// Format a Report Descriptor as a byte-level dump with human-readable descriptions
    /// - Parameters:
    ///   - parsedItems: Parsed items with raw bytes
    ///   - usageLookup: Usage table lookup for name resolution
    /// - Returns: Formatted string with byte-level dump
    public static func formatReportDescriptor(
        parsedItems: [ParsedItem],
        usageLookup: UsageTableLookupProtocol
    ) -> String {
        if parsedItems.isEmpty {
            return "No items found in Report Descriptor."
        }

        // Compute max byte column width for alignment
        let maxByteWidth = parsedItems.map { $0.rawBytes.count }.max() ?? 1
        // Each byte is "0xHH" (4 chars), joined by " " (1 char) → width = count * 5 - 1
        let padWidth = maxByteWidth * 5 - 1

        var lines: [String] = []
        var indentLevel = 0
        var currentUsagePage: UInt16 = 0

        for parsedItem in parsedItems {
            // Decrement indent before formatting End Collection
            if case .endCollection = parsedItem.item {
                indentLevel = max(0, indentLevel - 1)
            }

            let bytesStr = parsedItem.rawBytes.map { String(format: "0x%02X", $0) }.joined(separator: " ")
            let indent = String(repeating: "  ", count: indentLevel)
            let description = describeItem(parsedItem.item, currentUsagePage: currentUsagePage, usageLookup: usageLookup)

            let paddedBytes = bytesStr.padding(toLength: padWidth, withPad: " ", startingAt: 0)
            lines.append("\(paddedBytes) // \(indent)\(description)")

            // Track state
            if case .usagePage(let page) = parsedItem.item {
                currentUsagePage = page
            }

            // Increment indent after formatting Collection
            if case .collection = parsedItem.item {
                indentLevel += 1
            }
        }

        return lines.joined(separator: "\n")
    }

    /// Format a descriptor parse error with raw bytes fallback
    /// - Parameters:
    ///   - reason: Error reason description
    ///   - rawBytes: Raw descriptor bytes
    /// - Returns: Formatted error message with raw bytes
    public static func formatDescriptorError(reason: String, rawBytes: Data) -> String {
        var lines: [String] = []
        lines.append("Error: \(reason)")
        lines.append("")
        lines.append("Raw descriptor bytes:")
        lines.append(formatHexData(rawBytes))
        return lines.joined(separator: "\n")
    }

    // MARK: - Private Item Description

    private static func describeItem(
        _ item: ReportDescriptorItem,
        currentUsagePage: UInt16,
        usageLookup: UsageTableLookupProtocol
    ) -> String {
        switch item {
        case .usagePage(let page):
            let name = usageLookup.lookupPageName(page: page)
            return "Usage Page (\(name))"
        case .usage(let usage):
            if usage > 0xFFFF {
                // Extended usage: upper 16 bits = page, lower 16 bits = usage
                let page = UInt16((usage >> 16) & 0xFFFF)
                let usageId = UInt16(usage & 0xFFFF)
                let name = usageLookup.lookupUsageName(page: page, usage: usageId)
                return "Usage (\(name))"
            }
            let name = usageLookup.lookupUsageName(page: currentUsagePage, usage: UInt16(usage & 0xFFFF))
            return "Usage (\(name))"
        case .usageMinimum(let value):
            if value > 0xFFFF {
                let page = UInt16((value >> 16) & 0xFFFF)
                let usageId = UInt16(value & 0xFFFF)
                let name = usageLookup.lookupUsageName(page: page, usage: usageId)
                return "Usage Minimum (\(name))"
            }
            let name = usageLookup.lookupUsageName(page: currentUsagePage, usage: UInt16(value & 0xFFFF))
            return "Usage Minimum (\(name))"
        case .usageMaximum(let value):
            if value > 0xFFFF {
                let page = UInt16((value >> 16) & 0xFFFF)
                let usageId = UInt16(value & 0xFFFF)
                let name = usageLookup.lookupUsageName(page: page, usage: usageId)
                return "Usage Maximum (\(name))"
            }
            let name = usageLookup.lookupUsageName(page: currentUsagePage, usage: UInt16(value & 0xFFFF))
            return "Usage Maximum (\(name))"
        case .collection(let type):
            return "Collection (\(type.name))"
        case .endCollection:
            return "End Collection"
        case .input(let flags):
            return "Input (\(describeIOFlags(flags, isOutput: false)))"
        case .output(let flags):
            return "Output (\(describeIOFlags(flags, isOutput: true)))"
        case .feature(let flags):
            return "Feature (\(describeIOFlags(flags, isOutput: true)))"
        case .logicalMinimum(let value):
            return "Logical Minimum (\(value))"
        case .logicalMaximum(let value):
            return "Logical Maximum (\(value))"
        case .physicalMinimum(let value):
            return "Physical Minimum (\(value))"
        case .physicalMaximum(let value):
            return "Physical Maximum (\(value))"
        case .unitExponent(let value):
            return "Unit Exponent (\(value))"
        case .unit(let value):
            return "Unit (\(String(format: "0x%08X", value)))"
        case .reportSize(let value):
            return "Report Size (\(value))"
        case .reportId(let value):
            return "Report ID (\(value))"
        case .reportCount(let value):
            return "Report Count (\(value))"
        case .push:
            return "Push"
        case .pop:
            return "Pop"
        case .designatorIndex(let value):
            return "Designator Index (\(value))"
        case .designatorMinimum(let value):
            return "Designator Minimum (\(value))"
        case .designatorMaximum(let value):
            return "Designator Maximum (\(value))"
        case .stringIndex(let value):
            return "String Index (\(value))"
        case .stringMinimum(let value):
            return "String Minimum (\(value))"
        case .stringMaximum(let value):
            return "String Maximum (\(value))"
        case .delimiter(let value):
            return "Delimiter (\(value))"
        case .unknown(let tag, let data):
            let hex = data.map { String(format: "0x%02X", $0) }.joined(separator: " ")
            return "Unknown (tag=\(String(format: "0x%02X", tag)), data=\(hex))"
        }
    }

    /// Decode Input/Output/Feature flag bits into human-readable description
    private static func describeIOFlags(_ flags: UInt32, isOutput: Bool) -> String {
        let isConstant = (flags & 0x01) != 0
        let isVariable = (flags & 0x02) != 0
        let isRelative = (flags & 0x04) != 0
        let isWrap = (flags & 0x08) != 0
        let isNonLinear = (flags & 0x10) != 0
        let isNoPreferred = (flags & 0x20) != 0
        let isNullState = (flags & 0x40) != 0
        let isVolatile = (flags & 0x80) != 0
        let isBufferedBytes = (flags & 0x100) != 0

        if isConstant {
            var parts = ["Constant"]
            if isVariable { parts.append("Variable") }
            if isRelative { parts.append("Relative") }
            if isWrap { parts.append("Wrap") }
            if isNonLinear { parts.append("Non Linear") }
            if isNoPreferred { parts.append("No Preferred") }
            if isNullState { parts.append("Null state") }
            if isOutput && isVolatile { parts.append("Volatile") }
            if isBufferedBytes { parts.append("Buffered Bytes") }
            return parts.joined(separator: ", ")
        }

        // Data item: always show Data, Variable/Array, and Absolute/Relative if Variable
        var parts = ["Data"]
        if isVariable {
            parts.append("Variable")
            parts.append(isRelative ? "Relative" : "Absolute")
        } else {
            parts.append("Array")
            if isRelative { parts.append("Relative") }
        }

        // Show non-default flags
        if isWrap { parts.append("Wrap") }
        if isNonLinear { parts.append("Non Linear") }
        if isNoPreferred { parts.append("No Preferred") }
        if isNullState { parts.append("Null state") }
        if isOutput && isVolatile { parts.append("Volatile") }
        if isBufferedBytes { parts.append("Buffered Bytes") }

        return parts.joined(separator: ", ")
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
