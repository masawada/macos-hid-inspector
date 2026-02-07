import ArgumentParser
import Foundation

/// Lists all connected USB HID devices.
public struct ListCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List connected HID devices"
    )

    @Flag(name: .long, help: "Output in JSON format")
    public var json: Bool = false

    public init() {}

    public mutating func run() throws {
        let service = HIDDeviceService()

        do {
            let devices = try service.listDevices()

            let output: String
            if json {
                output = JSONFormatter.formatDeviceList(devices)
            } else {
                output = TextFormatter.formatDeviceList(devices)
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
