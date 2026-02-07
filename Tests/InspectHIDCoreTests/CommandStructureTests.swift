import Testing
import ArgumentParser
@testable import InspectHIDCore

/// Command structure tests for inspect-hid CLI
struct CommandStructureTests {

    @Test("InspectHID command name is 'inspect-hid'")
    func commandNameIsCorrect() throws {
        let config = InspectHID.configuration
        #expect(config.commandName == "inspect-hid")
    }

    @Test("InspectHID has abstract description")
    func commandHasAbstract() throws {
        let config = InspectHID.configuration
        #expect(!config.abstract.isEmpty)
    }

    @Test("InspectHID has 4 subcommands registered")
    func hasFourSubcommands() throws {
        let config = InspectHID.configuration
        #expect(config.subcommands.count == 4)
    }

    @Test("list subcommand is registered")
    func listSubcommandExists() throws {
        let config = InspectHID.configuration
        let subcommandNames = config.subcommands.map { $0.configuration.commandName ?? "" }
        #expect(subcommandNames.contains("list"))
    }

    @Test("descriptor subcommand is registered")
    func descriptorSubcommandExists() throws {
        let config = InspectHID.configuration
        let subcommandNames = config.subcommands.map { $0.configuration.commandName ?? "" }
        #expect(subcommandNames.contains("descriptor"))
    }

    @Test("usage subcommand is registered")
    func usageSubcommandExists() throws {
        let config = InspectHID.configuration
        let subcommandNames = config.subcommands.map { $0.configuration.commandName ?? "" }
        #expect(subcommandNames.contains("usage"))
    }

    @Test("monitor subcommand is registered")
    func monitorSubcommandExists() throws {
        let config = InspectHID.configuration
        let subcommandNames = config.subcommands.map { $0.configuration.commandName ?? "" }
        #expect(subcommandNames.contains("monitor"))
    }

    @Test("ListCommand has abstract description for help")
    func listCommandHasAbstract() throws {
        let config = ListCommand.configuration
        #expect(!config.abstract.isEmpty)
    }

    @Test("DescriptorCommand has abstract description for help")
    func descriptorCommandHasAbstract() throws {
        let config = DescriptorCommand.configuration
        #expect(!config.abstract.isEmpty)
    }

    @Test("UsageCommand has abstract description for help")
    func usageCommandHasAbstract() throws {
        let config = UsageCommand.configuration
        #expect(!config.abstract.isEmpty)
    }

    @Test("MonitorCommand has abstract description for help")
    func monitorCommandHasAbstract() throws {
        let config = MonitorCommand.configuration
        #expect(!config.abstract.isEmpty)
    }

    // MARK: - Subcommand-specific options

    @Test("ListCommand has --json flag")
    func listCommandHasJsonFlag() throws {
        // Test that ListCommand can be parsed with --json
        let command = try ListCommand.parse(["--json"])
        #expect(command.json == true)
    }

    @Test("ListCommand defaults to no JSON output")
    func listCommandDefaultsToTextOutput() throws {
        let command = try ListCommand.parse([])
        #expect(command.json == false)
    }

    @Test("DescriptorCommand requires device argument")
    func descriptorCommandRequiresDevice() throws {
        let command = try DescriptorCommand.parse(["1"])
        #expect(command.device == "1")
    }

    @Test("DescriptorCommand has --json flag")
    func descriptorCommandHasJsonFlag() throws {
        let command = try DescriptorCommand.parse(["1", "--json"])
        #expect(command.json == true)
    }

    @Test("UsageCommand requires device argument")
    func usageCommandRequiresDevice() throws {
        let command = try UsageCommand.parse(["0"])
        #expect(command.device == "0")
    }

    @Test("UsageCommand has --json flag")
    func usageCommandHasJsonFlag() throws {
        let command = try UsageCommand.parse(["0", "--json"])
        #expect(command.json == true)
    }

    @Test("MonitorCommand requires device argument")
    func monitorCommandRequiresDevice() throws {
        let command = try MonitorCommand.parse(["1"])
        #expect(command.device == "1")
    }

    @Test("MonitorCommand has --json flag")
    func monitorCommandHasJsonFlag() throws {
        let command = try MonitorCommand.parse(["1", "--json"])
        #expect(command.json == true)
    }

    @Test("Device can be specified as VID:PID format")
    func deviceCanBeVidPidFormat() throws {
        let command = try DescriptorCommand.parse(["1234:5678"])
        #expect(command.device == "1234:5678")
    }
}
