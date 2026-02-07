import Testing
import ArgumentParser
import Foundation
@testable import InspectHIDCore

/// E2E tests for all subcommands
/// These tests verify that all subcommands work correctly with --help and --json options.
@Suite("E2E Subcommand Tests")
struct E2ESubcommandTests {

    // MARK: - Verify all subcommands are operational

    @Test("All four subcommands are registered and accessible")
    func allSubcommandsRegistered() throws {
        let config = InspectHID.configuration

        // list, descriptor, usage, monitor subcommands
        let subcommandNames = Set(config.subcommands.map { $0.configuration.commandName ?? "" })

        #expect(subcommandNames.contains("list"), "list subcommand should be registered")
        #expect(subcommandNames.contains("descriptor"), "descriptor subcommand should be registered")
        #expect(subcommandNames.contains("usage"), "usage subcommand should be registered")
        #expect(subcommandNames.contains("monitor"), "monitor subcommand should be registered")
        #expect(config.subcommands.count == 4, "Should have exactly 4 subcommands")
    }

    // MARK: - --help option verification

    @Test("InspectHID main command has help text")
    func mainCommandHasHelp() throws {
        let config = InspectHID.configuration

        #expect(!config.abstract.isEmpty, "Main command should have abstract")
        #expect(config.commandName == "inspect-hid", "Command name should be inspect-hid")
    }

    @Test("ListCommand --help displays proper help text")
    func listCommandHelpText() throws {
        let config = ListCommand.configuration

        #expect(config.commandName == "list", "Command name should be 'list'")
        #expect(!config.abstract.isEmpty, "Should have abstract for help")
        #expect(config.abstract.lowercased().contains("list") ||
                config.abstract.lowercased().contains("device"),
                "Help should describe listing devices")
    }

    @Test("DescriptorCommand --help displays proper help text")
    func descriptorCommandHelpText() throws {
        let config = DescriptorCommand.configuration

        #expect(config.commandName == "descriptor", "Command name should be 'descriptor'")
        #expect(!config.abstract.isEmpty, "Should have abstract for help")
        #expect(config.abstract.lowercased().contains("descriptor") ||
                config.abstract.lowercased().contains("device"),
                "Help should describe device descriptor")
    }

    @Test("UsageCommand --help displays proper help text")
    func usageCommandHelpText() throws {
        let config = UsageCommand.configuration

        #expect(config.commandName == "usage", "Command name should be 'usage'")
        #expect(!config.abstract.isEmpty, "Should have abstract for help")
        #expect(config.abstract.lowercased().contains("usage") ||
                config.abstract.lowercased().contains("hid"),
                "Help should describe HID usage")
    }

    @Test("MonitorCommand --help displays proper help text")
    func monitorCommandHelpText() throws {
        let config = MonitorCommand.configuration

        #expect(config.commandName == "monitor", "Command name should be 'monitor'")
        #expect(!config.abstract.isEmpty, "Should have abstract for help")
        #expect(config.abstract.lowercased().contains("monitor") ||
                config.abstract.lowercased().contains("report"),
                "Help should describe monitoring reports")
    }

    // MARK: - --json option verification for all subcommands

    @Test("ListCommand accepts --json option")
    func listCommandAcceptsJsonOption() throws {
        // Verify --json parsing works
        let commandWithJson = try ListCommand.parse(["--json"])
        #expect(commandWithJson.json == true, "Should parse --json flag")

        let commandWithoutJson = try ListCommand.parse([])
        #expect(commandWithoutJson.json == false, "Should default to no JSON")
    }

    @Test("DescriptorCommand accepts --json option")
    func descriptorCommandAcceptsJsonOption() throws {
        // Verify --json parsing works with required device argument
        let commandWithJson = try DescriptorCommand.parse(["0", "--json"])
        #expect(commandWithJson.json == true, "Should parse --json flag")
        #expect(commandWithJson.device == "0", "Should preserve device argument")

        let commandWithoutJson = try DescriptorCommand.parse(["0"])
        #expect(commandWithoutJson.json == false, "Should default to no JSON")
    }

    @Test("UsageCommand accepts --json option")
    func usageCommandAcceptsJsonOption() throws {
        // Verify --json parsing works with required device argument
        let commandWithJson = try UsageCommand.parse(["0", "--json"])
        #expect(commandWithJson.json == true, "Should parse --json flag")
        #expect(commandWithJson.device == "0", "Should preserve device argument")

        let commandWithoutJson = try UsageCommand.parse(["0"])
        #expect(commandWithoutJson.json == false, "Should default to no JSON")
    }

    @Test("MonitorCommand accepts --json option")
    func monitorCommandAcceptsJsonOption() throws {
        // Verify --json parsing works with required device argument
        let commandWithJson = try MonitorCommand.parse(["0", "--json"])
        #expect(commandWithJson.json == true, "Should parse --json flag")
        #expect(commandWithJson.device == "0", "Should preserve device argument")

        let commandWithoutJson = try MonitorCommand.parse(["0"])
        #expect(commandWithoutJson.json == false, "Should default to no JSON")
    }

    // MARK: - Basic operation tests with mock adapter

    @Test("ListCommand runs successfully with mock devices")
    func listCommandRunsWithMockDevices() throws {
        // Given: A mock adapter with devices
        let devices = [
            MockHIDDeviceHandle(
                vendorId: 0x1234,
                productId: 0x5678,
                productName: "Test Device",
                manufacturer: "Test Corp",
                serialNumber: "SN001"
            )
        ]
        let mockAdapter = MockIOKitHIDAdapter(devices: devices)
        let service = HIDDeviceService(adapter: mockAdapter)

        // When: Listing devices
        let deviceInfos = try service.listDevices()

        // Then: Should return device info
        #expect(deviceInfos.count == 1)
        #expect(deviceInfos[0].vendorId == 0x1234)
        #expect(deviceInfos[0].productId == 0x5678)
    }

    @Test("ListCommand produces valid JSON output")
    func listCommandProducesValidJSON() throws {
        // Given: A mock adapter with devices
        let devices = [
            MockHIDDeviceHandle(
                vendorId: 0x1234,
                productId: 0x5678,
                productName: "Test Device",
                manufacturer: "Test Corp",
                serialNumber: "SN001"
            )
        ]
        let mockAdapter = MockIOKitHIDAdapter(devices: devices)
        let service = HIDDeviceService(adapter: mockAdapter)

        // When: Formatting as JSON
        let deviceInfos = try service.listDevices()
        let jsonOutput = JSONFormatter.formatDeviceList(deviceInfos)

        // Then: Should be valid JSON
        let jsonData = jsonOutput.data(using: .utf8)!
        let parsed = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]]
        #expect(parsed != nil, "Should produce valid JSON array")
        #expect(parsed?.count == 1, "Should contain one device")
    }

    @Test("DescriptorCommand resolves device and returns descriptor")
    func descriptorCommandResolvesDevice() throws {
        // Given: A mock adapter with a device
        let devices = [
            MockHIDDeviceHandle(
                vendorId: 0x1234,
                productId: 0x5678,
                productName: "Test Device",
                manufacturer: "Test Corp",
                serialNumber: "SN001"
            )
        ]
        let mockAdapter = MockIOKitHIDAdapter(devices: devices)
        let service = HIDDeviceService(adapter: mockAdapter)

        // When: Getting descriptor for device at index 0
        let descriptor = try service.getDeviceDescriptor(specifier: .index(0))

        // Then: Should return descriptor with device info
        #expect(descriptor.idVendor == 0x1234)
        #expect(descriptor.idProduct == 0x5678)
    }

    @Test("DescriptorCommand produces valid JSON output")
    func descriptorCommandProducesValidJSON() throws {
        // Given: A mock adapter with a device
        let devices = [
            MockHIDDeviceHandle(
                vendorId: 0x1234,
                productId: 0x5678,
                productName: "Test Device",
                manufacturer: "Test Corp",
                serialNumber: "SN001"
            )
        ]
        let mockAdapter = MockIOKitHIDAdapter(devices: devices)
        let service = HIDDeviceService(adapter: mockAdapter)

        // When: Getting descriptor and formatting as JSON
        let descriptor = try service.getDeviceDescriptor(specifier: .index(0))
        let jsonOutput = JSONFormatter.formatDeviceDescriptor(descriptor)

        // Then: Should be valid JSON
        let jsonData = jsonOutput.data(using: .utf8)!
        let parsed = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        #expect(parsed != nil, "Should produce valid JSON object")
        #expect(parsed?["idVendor"] != nil, "Should contain idVendor")
    }

    @Test("UsageCommand produces valid text output")
    func usageCommandProducesValidTextOutput() throws {
        // Given: A simple report descriptor
        let parser = ReportDescriptorParser()
        let usageLookup = UsageTableLookup()

        // Simple mouse descriptor: Usage Page (Generic Desktop), Usage (Mouse)
        let descriptorBytes = Data([
            0x05, 0x01,  // Usage Page (Generic Desktop)
            0x09, 0x02,  // Usage (Mouse)
            0xA1, 0x01,  // Collection (Application)
            0xC0         // End Collection
        ])

        // When: Parsing and formatting
        let descriptor = try parser.parse(data: descriptorBytes)
        let output = TextFormatter.formatReportDescriptor(
            collections: descriptor.collections,
            rawBytes: descriptor.rawBytes,
            usageLookup: usageLookup
        )

        // Then: Should contain usage information
        #expect(output.contains("Generic Desktop") || output.contains("0x01"),
                "Should contain usage page info")
    }

    @Test("UsageCommand produces valid JSON output")
    func usageCommandProducesValidJSONOutput() throws {
        // Given: A simple report descriptor
        let parser = ReportDescriptorParser()
        let usageLookup = UsageTableLookup()

        let descriptorBytes = Data([
            0x05, 0x01,  // Usage Page (Generic Desktop)
            0x09, 0x02,  // Usage (Mouse)
            0xA1, 0x01,  // Collection (Application)
            0xC0         // End Collection
        ])

        // When: Parsing and formatting as JSON
        let descriptor = try parser.parse(data: descriptorBytes)
        let jsonOutput = JSONFormatter.formatReportDescriptor(
            collections: descriptor.collections,
            rawBytes: descriptor.rawBytes,
            usageLookup: usageLookup
        )

        // Then: Should be valid JSON
        let jsonData = jsonOutput.data(using: .utf8)!
        let parsed = try JSONSerialization.jsonObject(with: jsonData)
        #expect(parsed is [String: Any], "Should produce valid JSON object")
    }

    @Test("MonitorCommand HIDReport produces valid text output")
    func monitorCommandTextOutput() throws {
        // Given: A HID report
        let report = HIDReport(
            timestamp: Date(),
            data: Data([0x01, 0x02, 0x03, 0x04]),
            reportId: 0
        )

        // When: Formatting as text
        let output = TextFormatter.formatHIDReport(report)

        // Then: Should contain hex data and timestamp
        #expect(output.contains("01") && output.contains("02"),
                "Should contain hex bytes")
    }

    @Test("MonitorCommand HIDReport produces valid JSON output")
    func monitorCommandJSONOutput() throws {
        // Given: A HID report
        let report = HIDReport(
            timestamp: Date(),
            data: Data([0x01, 0x02, 0x03, 0x04]),
            reportId: 0
        )

        // When: Formatting as JSON
        let jsonOutput = JSONFormatter.formatHIDReport(report)

        // Then: Should be valid JSON
        let jsonData = jsonOutput.data(using: .utf8)!
        let parsed = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        #expect(parsed != nil, "Should produce valid JSON")
        #expect(parsed?["timestamp"] != nil, "Should contain timestamp")
        #expect(parsed?["data"] != nil, "Should contain data")
    }

    // MARK: - VID:PID format support across commands

    @Test("Commands accept VID:PID format")
    func commandsAcceptVidPidFormat() throws {
        // Given: VID:PID format input
        let vidPid = "1234:5678"

        // When: Parsing commands with VID:PID
        let descriptorCmd = try DescriptorCommand.parse([vidPid])
        let usageCmd = try UsageCommand.parse([vidPid])
        let monitorCmd = try MonitorCommand.parse([vidPid])

        // Then: Should parse correctly
        #expect(descriptorCmd.device == vidPid)
        #expect(usageCmd.device == vidPid)
        #expect(monitorCmd.device == vidPid)
    }

    @Test("Commands accept index format")
    func commandsAcceptIndexFormat() throws {
        // Given: Index format input
        let index = "0"

        // When: Parsing commands with index
        let descriptorCmd = try DescriptorCommand.parse([index])
        let usageCmd = try UsageCommand.parse([index])
        let monitorCmd = try MonitorCommand.parse([index])

        // Then: Should parse correctly
        #expect(descriptorCmd.device == index)
        #expect(usageCmd.device == index)
        #expect(monitorCmd.device == index)
    }
}
