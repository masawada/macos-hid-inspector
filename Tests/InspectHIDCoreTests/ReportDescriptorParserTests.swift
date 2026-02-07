import Testing
import Foundation
@testable import InspectHIDCore

/// Tests for ReportDescriptorParser
@Suite("ReportDescriptorParser Tests")
struct ReportDescriptorParserTests {

    // MARK: - Basic Item Parsing Tests

    @Test("parse extracts Usage Page from short item")
    func parseUsagePage() throws {
        // Usage Page (Generic Desktop) = 0x05 0x01
        let data = Data([0x05, 0x01])
        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        #expect(descriptor.rawBytes == data)
        #expect(descriptor.items.count == 1)

        if case .usagePage(let page) = descriptor.items[0] {
            #expect(page == 0x01)
        } else {
            Issue.record("Expected UsagePage item")
        }
    }

    @Test("parse extracts Usage from short item")
    func parseUsage() throws {
        // Usage (Mouse) = 0x09 0x02
        let data = Data([0x09, 0x02])
        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        #expect(descriptor.items.count == 1)

        if case .usage(let usage) = descriptor.items[0] {
            #expect(usage == 0x02)
        } else {
            Issue.record("Expected Usage item")
        }
    }

    @Test("parse extracts 2-byte values correctly")
    func parseTwoByteValue() throws {
        // Usage Page (Vendor Defined) = 0x06 0x00 0xFF
        let data = Data([0x06, 0x00, 0xFF])
        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        #expect(descriptor.items.count == 1)

        if case .usagePage(let page) = descriptor.items[0] {
            #expect(page == 0xFF00)
        } else {
            Issue.record("Expected UsagePage item")
        }
    }

    @Test("parse extracts Collection item")
    func parseCollection() throws {
        // Collection (Application) = 0xA1 0x01
        let data = Data([0xA1, 0x01])
        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        #expect(descriptor.items.count == 1)

        if case .collection(let collectionType) = descriptor.items[0] {
            #expect(collectionType == .application)
        } else {
            Issue.record("Expected Collection item")
        }
    }

    @Test("parse extracts End Collection item")
    func parseEndCollection() throws {
        // End Collection = 0xC0
        let data = Data([0xC0])
        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        #expect(descriptor.items.count == 1)

        if case .endCollection = descriptor.items[0] {
            // Success
        } else {
            Issue.record("Expected EndCollection item")
        }
    }

    // MARK: - Report Item Parsing Tests

    @Test("parse extracts Report ID")
    func parseReportId() throws {
        // Report ID (1) = 0x85 0x01
        let data = Data([0x85, 0x01])
        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        #expect(descriptor.items.count == 1)

        if case .reportId(let id) = descriptor.items[0] {
            #expect(id == 1)
        } else {
            Issue.record("Expected ReportId item")
        }
    }

    @Test("parse extracts Report Size")
    func parseReportSize() throws {
        // Report Size (8) = 0x75 0x08
        let data = Data([0x75, 0x08])
        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        #expect(descriptor.items.count == 1)

        if case .reportSize(let size) = descriptor.items[0] {
            #expect(size == 8)
        } else {
            Issue.record("Expected ReportSize item")
        }
    }

    @Test("parse extracts Report Count")
    func parseReportCount() throws {
        // Report Count (3) = 0x95 0x03
        let data = Data([0x95, 0x03])
        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        #expect(descriptor.items.count == 1)

        if case .reportCount(let count) = descriptor.items[0] {
            #expect(count == 3)
        } else {
            Issue.record("Expected ReportCount item")
        }
    }

    @Test("parse extracts Input item")
    func parseInput() throws {
        // Input (Data, Variable, Relative) = 0x81 0x06
        let data = Data([0x81, 0x06])
        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        #expect(descriptor.items.count == 1)

        if case .input(let flags) = descriptor.items[0] {
            #expect(flags == 0x06)
        } else {
            Issue.record("Expected Input item")
        }
    }

    @Test("parse extracts Output item")
    func parseOutput() throws {
        // Output (Data, Variable, Absolute) = 0x91 0x02
        let data = Data([0x91, 0x02])
        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        #expect(descriptor.items.count == 1)

        if case .output(let flags) = descriptor.items[0] {
            #expect(flags == 0x02)
        } else {
            Issue.record("Expected Output item")
        }
    }

    @Test("parse extracts Feature item")
    func parseFeature() throws {
        // Feature (Data, Variable, Absolute) = 0xB1 0x02
        let data = Data([0xB1, 0x02])
        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        #expect(descriptor.items.count == 1)

        if case .feature(let flags) = descriptor.items[0] {
            #expect(flags == 0x02)
        } else {
            Issue.record("Expected Feature item")
        }
    }

    // MARK: - Global Item Tests

    @Test("parse extracts Logical Minimum")
    func parseLogicalMinimum() throws {
        // Logical Minimum (0) = 0x15 0x00
        let data = Data([0x15, 0x00])
        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        #expect(descriptor.items.count == 1)

        if case .logicalMinimum(let value) = descriptor.items[0] {
            #expect(value == 0)
        } else {
            Issue.record("Expected LogicalMinimum item")
        }
    }

    @Test("parse extracts Logical Maximum")
    func parseLogicalMaximum() throws {
        // Logical Maximum (255) = 0x26 0xFF 0x00 (2-byte unsigned to avoid sign extension)
        let data = Data([0x26, 0xFF, 0x00])
        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        #expect(descriptor.items.count == 1)

        if case .logicalMaximum(let value) = descriptor.items[0] {
            #expect(value == 255)
        } else {
            Issue.record("Expected LogicalMaximum item")
        }
    }

    @Test("parse extracts Usage Minimum")
    func parseUsageMinimum() throws {
        // Usage Minimum (1) = 0x19 0x01
        let data = Data([0x19, 0x01])
        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        #expect(descriptor.items.count == 1)

        if case .usageMinimum(let value) = descriptor.items[0] {
            #expect(value == 1)
        } else {
            Issue.record("Expected UsageMinimum item")
        }
    }

    @Test("parse extracts Usage Maximum")
    func parseUsageMaximum() throws {
        // Usage Maximum (3) = 0x29 0x03
        let data = Data([0x29, 0x03])
        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        #expect(descriptor.items.count == 1)

        if case .usageMaximum(let value) = descriptor.items[0] {
            #expect(value == 3)
        } else {
            Issue.record("Expected UsageMaximum item")
        }
    }

    // MARK: - Collection Type Tests

    @Test("parse identifies Physical collection")
    func parsePhysicalCollection() throws {
        // Collection (Physical) = 0xA1 0x00
        let data = Data([0xA1, 0x00])
        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        if case .collection(let collectionType) = descriptor.items[0] {
            #expect(collectionType == .physical)
        } else {
            Issue.record("Expected Collection item")
        }
    }

    @Test("parse identifies Application collection")
    func parseApplicationCollection() throws {
        // Collection (Application) = 0xA1 0x01
        let data = Data([0xA1, 0x01])
        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        if case .collection(let collectionType) = descriptor.items[0] {
            #expect(collectionType == .application)
        } else {
            Issue.record("Expected Collection item")
        }
    }

    @Test("parse identifies Logical collection")
    func parseLogicalCollection() throws {
        // Collection (Logical) = 0xA1 0x02
        let data = Data([0xA1, 0x02])
        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        if case .collection(let collectionType) = descriptor.items[0] {
            #expect(collectionType == .logical)
        } else {
            Issue.record("Expected Collection item")
        }
    }

    @Test("parse identifies Report collection")
    func parseReportCollection() throws {
        // Collection (Report) = 0xA1 0x03
        let data = Data([0xA1, 0x03])
        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        if case .collection(let collectionType) = descriptor.items[0] {
            #expect(collectionType == .report)
        } else {
            Issue.record("Expected Collection item")
        }
    }

    @Test("parse identifies Named Array collection")
    func parseNamedArrayCollection() throws {
        // Collection (Named Array) = 0xA1 0x04
        let data = Data([0xA1, 0x04])
        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        if case .collection(let collectionType) = descriptor.items[0] {
            #expect(collectionType == .namedArray)
        } else {
            Issue.record("Expected Collection item")
        }
    }

    @Test("parse identifies Usage Switch collection")
    func parseUsageSwitchCollection() throws {
        // Collection (Usage Switch) = 0xA1 0x05
        let data = Data([0xA1, 0x05])
        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        if case .collection(let collectionType) = descriptor.items[0] {
            #expect(collectionType == .usageSwitch)
        } else {
            Issue.record("Expected Collection item")
        }
    }

    @Test("parse identifies Usage Modifier collection")
    func parseUsageModifierCollection() throws {
        // Collection (Usage Modifier) = 0xA1 0x06
        let data = Data([0xA1, 0x06])
        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        if case .collection(let collectionType) = descriptor.items[0] {
            #expect(collectionType == .usageModifier)
        } else {
            Issue.record("Expected Collection item")
        }
    }

    // MARK: - Complete Descriptor Tests

    @Test("parse simple mouse descriptor")
    func parseSimpleMouseDescriptor() throws {
        // Simple mouse descriptor
        let data = Data([
            0x05, 0x01,  // Usage Page (Generic Desktop)
            0x09, 0x02,  // Usage (Mouse)
            0xA1, 0x01,  // Collection (Application)
            0x09, 0x01,  //   Usage (Pointer)
            0xA1, 0x00,  //   Collection (Physical)
            0x05, 0x09,  //     Usage Page (Button)
            0x19, 0x01,  //     Usage Minimum (1)
            0x29, 0x03,  //     Usage Maximum (3)
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

        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        #expect(descriptor.rawBytes == data)
        #expect(descriptor.items.count > 0)

        // Verify first items
        if case .usagePage(let page) = descriptor.items[0] {
            #expect(page == 0x01)  // Generic Desktop
        } else {
            Issue.record("Expected UsagePage as first item")
        }

        if case .usage(let usage) = descriptor.items[1] {
            #expect(usage == 0x02)  // Mouse
        } else {
            Issue.record("Expected Usage as second item")
        }

        if case .collection(let collectionType) = descriptor.items[2] {
            #expect(collectionType == .application)
        } else {
            Issue.record("Expected Application collection as third item")
        }
    }

    @Test("parse builds collection tree structure")
    func parseBuildCollectionTree() throws {
        // Simple descriptor with nested collections
        let data = Data([
            0x05, 0x01,  // Usage Page (Generic Desktop)
            0x09, 0x02,  // Usage (Mouse)
            0xA1, 0x01,  // Collection (Application)
            0x09, 0x01,  //   Usage (Pointer)
            0xA1, 0x00,  //   Collection (Physical)
            0xC0,        //   End Collection
            0xC0         // End Collection
        ])

        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        #expect(descriptor.collections.count == 1)

        let rootCollection = descriptor.collections[0]
        #expect(rootCollection.type == .application)
        #expect(rootCollection.usagePage == 0x01)
        #expect(rootCollection.usage == 0x02)
        #expect(rootCollection.children.count == 1)

        let childCollection = rootCollection.children[0]
        #expect(childCollection.type == .physical)
        #expect(childCollection.usage == 0x01)
    }

    // MARK: - Error Handling Tests

    @Test("parse empty data returns empty descriptor")
    func parseEmptyData() throws {
        let data = Data()
        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        #expect(descriptor.rawBytes == data)
        #expect(descriptor.items.isEmpty)
        #expect(descriptor.collections.isEmpty)
    }

    @Test("parse handles truncated data gracefully")
    func parseTruncatedData() throws {
        // Incomplete item: Usage Page without value byte
        let data = Data([0x05])
        let parser = ReportDescriptorParser()

        // Should throw or return partial parse with fallback
        do {
            let descriptor = try parser.parse(data: data)
            // If it doesn't throw, should still have raw bytes
            #expect(descriptor.rawBytes == data)
        } catch let error as InspectHIDError {
            // Expected behavior: fallback error with raw data
            if case .descriptorParseFailed = error {
                // Success - error contains reason
            } else {
                Issue.record("Unexpected error type: \(error)")
            }
        }
    }

    @Test("parse unknown item tag preserved as unknown item")
    func parseUnknownItem() throws {
        // Long item format: 0xFE + bDataSize(1) + bLongItemTag(1) + data(bDataSize)
        // This creates a long item with tag 0x10 and 2 bytes of data [0xAB, 0xCD]
        let data = Data([0xFE, 0x02, 0x10, 0xAB, 0xCD])
        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        #expect(descriptor.rawBytes == data)
        // Parser should handle unknown long items
        #expect(descriptor.items.count == 1)

        if case .unknown(let tag, let itemData) = descriptor.items[0] {
            #expect(tag == 0x10)
            #expect(itemData == Data([0xAB, 0xCD]))
        } else {
            Issue.record("Expected unknown item")
        }
    }

    // MARK: - Signed Value Tests

    @Test("parse negative logical minimum")
    func parseNegativeLogicalMinimum() throws {
        // Logical Minimum (-127) = 0x15 0x81 (signed byte)
        let data = Data([0x15, 0x81])
        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        if case .logicalMinimum(let value) = descriptor.items[0] {
            #expect(value == -127)
        } else {
            Issue.record("Expected LogicalMinimum item")
        }
    }

    @Test("parse 2-byte negative value")
    func parseTwoByteNegativeValue() throws {
        // Logical Minimum (-32768) = 0x16 0x00 0x80
        let data = Data([0x16, 0x00, 0x80])
        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        if case .logicalMinimum(let value) = descriptor.items[0] {
            #expect(value == -32768)
        } else {
            Issue.record("Expected LogicalMinimum item")
        }
    }

    // MARK: - Protocol Conformance Tests

    @Test("ReportDescriptorParser conforms to ReportDescriptorParserProtocol")
    func protocolConformance() throws {
        let parser: any ReportDescriptorParserProtocol = ReportDescriptorParser()
        let data = Data([0x05, 0x01])
        let descriptor = try parser.parse(data: data)
        #expect(descriptor.rawBytes == data)
    }

    // MARK: - Push/Pop Tests

    @Test("parse handles Push and Pop items")
    func parsePushPop() throws {
        // Push = 0xA4, Pop = 0xB4
        let data = Data([
            0x05, 0x01,  // Usage Page (Generic Desktop)
            0xA4,        // Push
            0x05, 0x09,  // Usage Page (Button)
            0xB4,        // Pop
            0x09, 0x30   // Usage (X) - should use Generic Desktop after pop
        ])
        let parser = ReportDescriptorParser()
        let descriptor = try parser.parse(data: data)

        #expect(descriptor.items.count == 5)

        // Check that Push is parsed
        if case .push = descriptor.items[1] {
            // Success
        } else {
            Issue.record("Expected Push item")
        }

        // Check that Pop is parsed
        if case .pop = descriptor.items[3] {
            // Success
        } else {
            Issue.record("Expected Pop item")
        }
    }
}
