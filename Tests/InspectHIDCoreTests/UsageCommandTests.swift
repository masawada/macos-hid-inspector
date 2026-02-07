import Testing
import Foundation
@testable import InspectHIDCore

/// Tests for UsageCommand
@Suite("UsageCommand Tests")
struct UsageCommandTests {

    // MARK: - Command Configuration Tests

    @Test("UsageCommand has correct configuration")
    func commandConfiguration() {
        #expect(UsageCommand.configuration.commandName == "usage")
        #expect(UsageCommand.configuration.abstract == "Show HID usage information for a device")
    }

    @Test("UsageCommand accepts device argument")
    func acceptsDeviceArgument() throws {
        let command = try UsageCommand.parse(["0"])
        #expect(command.device == "0")
    }

    @Test("UsageCommand accepts json flag")
    func acceptsJsonFlag() throws {
        let commandWithoutJson = try UsageCommand.parse(["0"])
        #expect(commandWithoutJson.json == false)

        let commandWithJson = try UsageCommand.parse(["0", "--json"])
        #expect(commandWithJson.json == true)
    }
}

/// Tests for TextFormatter Usage formatting (byte-level dump format)
@Suite("TextFormatter Usage Tests")
struct TextFormatterUsageTests {

    @Test("formatReportDescriptor displays byte-level dump with descriptions")
    func formatByteLevelDump() {
        let lookup = UsageTableLookup()
        let parser = ReportDescriptorParser()
        let data = Data([
            0x05, 0x01,  // Usage Page (Generic Desktop)
            0x09, 0x02,  // Usage (Mouse)
            0xA1, 0x01,  // Collection (Application)
            0x09, 0x01,  //   Usage (Pointer)
            0xA1, 0x00,  //   Collection (Physical)
            0xC0,        //   End Collection
            0xC0         // End Collection
        ])
        let descriptor = try! parser.parse(data: data)

        let output = TextFormatter.formatReportDescriptor(
            parsedItems: descriptor.parsedItems,
            usageLookup: lookup
        )

        // Verify byte-level hex dump
        #expect(output.contains("0x05 0x01"))
        #expect(output.contains("0x09 0x02"))
        #expect(output.contains("0xA1 0x01"))
        #expect(output.contains("0xC0"))

        // Verify descriptions
        #expect(output.contains("Usage Page (Generic Desktop Page)"))
        #expect(output.contains("Usage (Mouse)"))
        #expect(output.contains("Collection (Application)"))
        #expect(output.contains("Collection (Physical)"))
        #expect(output.contains("End Collection"))
    }

    @Test("formatReportDescriptor displays Usage Page name")
    func formatUsagePageName() {
        let lookup = UsageTableLookup()
        let parsedItems = [
            ParsedItem(item: .usagePage(0x01), rawBytes: Data([0x05, 0x01]))
        ]

        let output = TextFormatter.formatReportDescriptor(
            parsedItems: parsedItems,
            usageLookup: lookup
        )

        #expect(output.contains("Generic Desktop Page"))
    }

    @Test("formatReportDescriptor displays Usage name")
    func formatUsageName() {
        let lookup = UsageTableLookup()
        let parsedItems = [
            ParsedItem(item: .usagePage(0x01), rawBytes: Data([0x05, 0x01])),
            ParsedItem(item: .usage(0x02), rawBytes: Data([0x09, 0x02]))
        ]

        let output = TextFormatter.formatReportDescriptor(
            parsedItems: parsedItems,
            usageLookup: lookup
        )

        #expect(output.contains("Usage (Mouse)"))
    }

    @Test("formatReportDescriptor shows hex for unknown Usage Page")
    func formatUnknownUsagePage() {
        let lookup = UsageTableLookup()
        let parsedItems = [
            ParsedItem(item: .usagePage(0xFFFF), rawBytes: Data([0x06, 0xFF, 0xFF]))
        ]

        let output = TextFormatter.formatReportDescriptor(
            parsedItems: parsedItems,
            usageLookup: lookup
        )

        #expect(output.contains("0xFFFF"))
    }

    @Test("formatReportDescriptor shows raw bytes on parse failure")
    func formatRawBytesOnFailure() {
        let rawBytes = Data([0x05, 0x01, 0x09, 0x02])

        let output = TextFormatter.formatDescriptorError(
            reason: "Parse error",
            rawBytes: rawBytes
        )

        #expect(output.contains("Parse error"))
        #expect(output.contains("05 01 09 02"))
    }

    @Test("formatReportDescriptor handles empty parsed items")
    func formatEmptyParsedItems() {
        let lookup = UsageTableLookup()
        let parsedItems: [ParsedItem] = []

        let output = TextFormatter.formatReportDescriptor(
            parsedItems: parsedItems,
            usageLookup: lookup
        )

        #expect(output.contains("No items found"))
    }

    @Test("formatReportDescriptor indents inside collections")
    func formatIndentation() {
        let lookup = UsageTableLookup()
        let parser = ReportDescriptorParser()
        let data = Data([
            0x05, 0x01,  // Usage Page (Generic Desktop)
            0x09, 0x02,  // Usage (Mouse)
            0xA1, 0x01,  // Collection (Application)
            0x09, 0x01,  //   Usage (Pointer)
            0xA1, 0x00,  //   Collection (Physical)
            0x05, 0x09,  //     Usage Page (Button)
            0xC0,        //   End Collection
            0xC0         // End Collection
        ])
        let descriptor = try! parser.parse(data: data)

        let output = TextFormatter.formatReportDescriptor(
            parsedItems: descriptor.parsedItems,
            usageLookup: lookup
        )

        let lines = output.split(separator: "\n").map(String.init)

        // Items inside Application collection should be indented with 2 spaces
        let pointerLine = lines.first { $0.contains("Usage (Pointer)") }!
        #expect(pointerLine.contains("//   Usage"))

        // Items inside Physical collection should be indented with 4 spaces
        let buttonLine = lines.first { $0.contains("Usage Page (Button)") }!
        #expect(buttonLine.contains("//     Usage Page"))
    }

    @Test("formatReportDescriptor decodes Input flags")
    func formatInputFlags() {
        let lookup = UsageTableLookup()
        let parsedItems = [
            ParsedItem(item: .input(0x02), rawBytes: Data([0x81, 0x02])),
            ParsedItem(item: .input(0x06), rawBytes: Data([0x81, 0x06])),
            ParsedItem(item: .input(0x01), rawBytes: Data([0x81, 0x01]))
        ]

        let output = TextFormatter.formatReportDescriptor(
            parsedItems: parsedItems,
            usageLookup: lookup
        )

        #expect(output.contains("Input (Data, Variable, Absolute)"))
        #expect(output.contains("Input (Data, Variable, Relative)"))
        #expect(output.contains("Input (Constant)"))
    }

    @Test("formatReportDescriptor decodes Output flags")
    func formatOutputFlags() {
        let lookup = UsageTableLookup()
        let parsedItems = [
            ParsedItem(item: .output(0x02), rawBytes: Data([0x91, 0x02]))
        ]

        let output = TextFormatter.formatReportDescriptor(
            parsedItems: parsedItems,
            usageLookup: lookup
        )

        #expect(output.contains("Output (Data, Variable, Absolute)"))
    }

    @Test("formatReportDescriptor decodes Feature flags")
    func formatFeatureFlags() {
        let lookup = UsageTableLookup()
        let parsedItems = [
            ParsedItem(item: .feature(0x02), rawBytes: Data([0xB1, 0x02]))
        ]

        let output = TextFormatter.formatReportDescriptor(
            parsedItems: parsedItems,
            usageLookup: lookup
        )

        #expect(output.contains("Feature (Data, Variable, Absolute)"))
    }

    @Test("formatReportDescriptor full mouse descriptor")
    func formatFullMouseDescriptor() {
        let lookup = UsageTableLookup()
        let parser = ReportDescriptorParser()
        let data = Data([
            0x05, 0x01,  // Usage Page (Generic Desktop)
            0x09, 0x02,  // Usage (Mouse)
            0xA1, 0x01,  // Collection (Application)
            0x09, 0x01,  //   Usage (Pointer)
            0xA1, 0x00,  //   Collection (Physical)
            0x05, 0x09,  //     Usage Page (Button)
            0x19, 0x01,  //     Usage Minimum (Button 1)
            0x29, 0x03,  //     Usage Maximum (Button 3)
            0x15, 0x00,  //     Logical Minimum (0)
            0x25, 0x01,  //     Logical Maximum (1)
            0x95, 0x03,  //     Report Count (3)
            0x75, 0x01,  //     Report Size (1)
            0x81, 0x02,  //     Input (Data, Variable, Absolute)
            0x95, 0x01,  //     Report Count (1)
            0x75, 0x05,  //     Report Size (5)
            0x81, 0x01,  //     Input (Constant)
            0x05, 0x01,  //     Usage Page (Generic Desktop)
            0x09, 0x30,  //     Usage (X)
            0x09, 0x31,  //     Usage (Y)
            0x15, 0x81,  //     Logical Minimum (-127)
            0x25, 0x7F,  //     Logical Maximum (127)
            0x75, 0x08,  //     Report Size (8)
            0x95, 0x02,  //     Report Count (2)
            0x81, 0x06,  //     Input (Data, Variable, Relative)
            0xC0,        //   End Collection
            0xC0         // End Collection
        ])
        let descriptor = try! parser.parse(data: data)

        let output = TextFormatter.formatReportDescriptor(
            parsedItems: descriptor.parsedItems,
            usageLookup: lookup
        )

        // Verify key elements
        #expect(output.contains("Usage Page (Generic Desktop Page)"))
        #expect(output.contains("Usage (Mouse)"))
        #expect(output.contains("Collection (Application)"))
        #expect(output.contains("Usage (Pointer)"))
        #expect(output.contains("Collection (Physical)"))
        #expect(output.contains("Usage Page (Button)"))
        #expect(output.contains("Usage Minimum (Button 1)"))
        #expect(output.contains("Usage Maximum (Button 3)"))
        #expect(output.contains("Logical Minimum (0)"))
        #expect(output.contains("Logical Maximum (1)"))
        #expect(output.contains("Report Count (3)"))
        #expect(output.contains("Report Size (1)"))
        #expect(output.contains("Input (Data, Variable, Absolute)"))
        #expect(output.contains("Input (Constant)"))
        #expect(output.contains("Usage (X)"))
        #expect(output.contains("Usage (Y)"))
        #expect(output.contains("Logical Minimum (-127)"))
        #expect(output.contains("Logical Maximum (127)"))
        #expect(output.contains("Input (Data, Variable, Relative)"))
        #expect(output.contains("End Collection"))
    }
}

/// Tests for JSONFormatter Usage formatting
@Suite("JSONFormatter Usage Tests")
struct JSONFormatterUsageTests {

    @Test("formatReportDescriptor outputs valid JSON")
    func formatValidJson() throws {
        let lookup = UsageTableLookup()
        let collections = [
            CollectionNode(
                usagePage: 0x01,
                usage: 0x02,
                type: .application,
                children: [],
                items: []
            )
        ]

        let output = JSONFormatter.formatReportDescriptor(
            collections: collections,
            rawBytes: Data([0x05, 0x01]),
            usageLookup: lookup
        )

        // Verify it's valid JSON
        let data = output.data(using: .utf8)!
        let json = try JSONSerialization.jsonObject(with: data)
        #expect(json is [String: Any])
    }

    @Test("formatReportDescriptor includes collection structure")
    func formatCollectionStructure() throws {
        let lookup = UsageTableLookup()
        let collections = [
            CollectionNode(
                usagePage: 0x01,
                usage: 0x02,
                type: .application,
                children: [],
                items: []
            )
        ]

        let output = JSONFormatter.formatReportDescriptor(
            collections: collections,
            rawBytes: Data(),
            usageLookup: lookup
        )

        #expect(output.contains("collections"))
        #expect(output.contains("usagePage"))
        #expect(output.contains("usage"))
        #expect(output.contains("type"))
    }

    @Test("formatReportDescriptor includes usage names")
    func formatUsageNames() {
        let lookup = UsageTableLookup()
        let collections = [
            CollectionNode(
                usagePage: 0x01,
                usage: 0x02,
                type: .application,
                children: [],
                items: []
            )
        ]

        let output = JSONFormatter.formatReportDescriptor(
            collections: collections,
            rawBytes: Data(),
            usageLookup: lookup
        )

        #expect(output.contains("usagePageName"))
        #expect(output.contains("usageName"))
        #expect(output.contains("Generic Desktop Page"))
        #expect(output.contains("Mouse"))
    }

    @Test("formatReportDescriptor includes raw bytes as hex string")
    func formatRawBytes() {
        let lookup = UsageTableLookup()
        let rawBytes = Data([0x05, 0x01, 0x09, 0x02])

        let output = JSONFormatter.formatReportDescriptor(
            collections: [],
            rawBytes: rawBytes,
            usageLookup: lookup
        )

        #expect(output.contains("rawBytes"))
        #expect(output.contains("05 01 09 02"))
    }

    @Test("formatDescriptorError outputs error JSON")
    func formatErrorJson() throws {
        let rawBytes = Data([0x05, 0x01])

        let output = JSONFormatter.formatDescriptorError(
            reason: "Parse error at byte 2",
            rawBytes: rawBytes
        )

        let data = output.data(using: .utf8)!
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["error"] as? String == "Parse error at byte 2")
        #expect(json["rawBytes"] as? String == "05 01")
    }
}
