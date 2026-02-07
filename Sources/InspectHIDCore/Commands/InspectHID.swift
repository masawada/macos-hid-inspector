import ArgumentParser

/// Main entry point for the inspect-hid CLI tool.
/// Provides subcommand-based interface for USB HID device inspection on macOS.
public struct InspectHID: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "inspect-hid",
        abstract: "Inspect Human Interface Devices (HID) connected to the system",
        version: InspectHIDCore.version,
        subcommands: [
            ListCommand.self,
            DescriptorCommand.self,
            UsageCommand.self,
            MonitorCommand.self
        ]
    )

    public init() {}
}
