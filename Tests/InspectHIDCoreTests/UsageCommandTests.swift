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

/// Tests for TextFormatter Usage formatting
@Suite("TextFormatter Usage Tests")
struct TextFormatterUsageTests {

    @Test("formatReportDescriptor displays collection hierarchy with indentation")
    func formatCollectionHierarchy() {
        let lookup = UsageTableLookup()
        let collections = [
            CollectionNode(
                usagePage: 0x01,  // Generic Desktop
                usage: 0x02,     // Mouse
                type: .application,
                children: [
                    CollectionNode(
                        usagePage: 0x01,
                        usage: 0x01,  // Pointer
                        type: .physical,
                        children: [],
                        items: []
                    )
                ],
                items: []
            )
        ]

        let output = TextFormatter.formatReportDescriptor(
            collections: collections,
            rawBytes: Data([0x05, 0x01]),
            usageLookup: lookup
        )

        // Verify collection hierarchy with indentation
        #expect(output.contains("Collection (Application)"))
        #expect(output.contains("Usage Page: Generic Desktop Page"))
        #expect(output.contains("Usage: Mouse"))
        #expect(output.contains("Collection (Physical)"))
        #expect(output.contains("Pointer"))
    }

    @Test("formatReportDescriptor displays Usage Page name")
    func formatUsagePageName() {
        let lookup = UsageTableLookup()
        let collections = [
            CollectionNode(
                usagePage: 0x01,  // Generic Desktop
                usage: 0x02,
                type: .application,
                children: [],
                items: []
            )
        ]

        let output = TextFormatter.formatReportDescriptor(
            collections: collections,
            rawBytes: Data(),
            usageLookup: lookup
        )

        #expect(output.contains("Generic Desktop Page"))
    }

    @Test("formatReportDescriptor displays Usage name")
    func formatUsageName() {
        let lookup = UsageTableLookup()
        let collections = [
            CollectionNode(
                usagePage: 0x01,  // Generic Desktop
                usage: 0x02,     // Mouse
                type: .application,
                children: [],
                items: []
            )
        ]

        let output = TextFormatter.formatReportDescriptor(
            collections: collections,
            rawBytes: Data(),
            usageLookup: lookup
        )

        #expect(output.contains("Mouse"))
    }

    @Test("formatReportDescriptor shows hex for unknown Usage Page")
    func formatUnknownUsagePage() {
        let lookup = UsageTableLookup()
        let collections = [
            CollectionNode(
                usagePage: 0xFFFF,  // Unknown
                usage: 0x01,
                type: .application,
                children: [],
                items: []
            )
        ]

        let output = TextFormatter.formatReportDescriptor(
            collections: collections,
            rawBytes: Data(),
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

    @Test("formatReportDescriptor handles empty collections")
    func formatEmptyCollections() {
        let lookup = UsageTableLookup()
        let collections: [CollectionNode] = []

        let output = TextFormatter.formatReportDescriptor(
            collections: collections,
            rawBytes: Data(),
            usageLookup: lookup
        )

        #expect(output.contains("No collections found"))
    }

    @Test("formatReportDescriptor displays nested children with proper indentation")
    func formatNestedChildren() {
        let lookup = UsageTableLookup()
        let collections = [
            CollectionNode(
                usagePage: 0x01,
                usage: 0x02,
                type: .application,
                children: [
                    CollectionNode(
                        usagePage: 0x01,
                        usage: 0x01,
                        type: .physical,
                        children: [
                            CollectionNode(
                                usagePage: 0x09,  // Button
                                usage: 0x01,
                                type: .logical,
                                children: [],
                                items: []
                            )
                        ],
                        items: []
                    )
                ],
                items: []
            )
        ]

        let output = TextFormatter.formatReportDescriptor(
            collections: collections,
            rawBytes: Data(),
            usageLookup: lookup
        )

        // Check proper nesting exists
        #expect(output.contains("Application"))
        #expect(output.contains("Physical"))
        #expect(output.contains("Logical"))
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
