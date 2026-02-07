import ArgumentParser
import Foundation

/// Displays Device Descriptor information for a specified HID device.
public struct DescriptorCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "descriptor",
        abstract: "Show device descriptor for a HID device"
    )

    @Argument(help: "Device specifier (index or VID:PID)")
    public var device: String

    @Flag(name: .long, help: "Output in JSON format")
    public var json: Bool = false

    public init() {}

    public mutating func run() throws {
        let service = HIDDeviceService()
        let selector = DeviceSelector()

        do {
            // Parse device specifier
            let specifier = try selector.parse(input: device)

            // Get device descriptor
            let descriptor = try service.getDeviceDescriptor(specifier: specifier)

            // Format and output
            let output: String
            if json {
                output = JSONFormatter.formatDeviceDescriptor(descriptor)
            } else {
                output = TextFormatter.formatDeviceDescriptor(descriptor)
            }

            print(output)
        } catch let error as InspectHIDError {
            FileHandle.standardError.write(Data((TextFormatter.formatError(error) + "\n").utf8))
            throw ExitCode(error.exitCode)
        } catch {
            FileHandle.standardError.write(Data((TextFormatter.formatError(error) + "\n").utf8))
            throw ExitCode.failure
        }
    }
}
