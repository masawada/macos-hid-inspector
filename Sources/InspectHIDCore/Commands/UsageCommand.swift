import ArgumentParser
import Foundation

/// Displays HID Report Descriptor usage information for a specified device.
public struct UsageCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "usage",
        abstract: "Show HID usage information for a device"
    )

    @Argument(help: "Device specifier (index or VID:PID)")
    public var device: String

    @Flag(name: .long, help: "Output in JSON format")
    public var json: Bool = false

    public init() {}

    public mutating func run() throws {
        let selector = DeviceSelector()
        let service = HIDDeviceService()
        let parser = ReportDescriptorParser()
        let usageLookup = UsageTableLookup()

        // Parse device specifier
        let specifier: DeviceSpecifier
        do {
            specifier = try selector.parse(input: device)
        } catch let error as InspectHIDError {
            printError(error)
            throw ExitCode(error.exitCode)
        }

        // Get report descriptor
        let descriptorData: Data
        do {
            descriptorData = try service.getReportDescriptor(specifier: specifier)
        } catch let error as InspectHIDError {
            printError(error)
            throw ExitCode(error.exitCode)
        }

        // Parse report descriptor
        do {
            let descriptor = try parser.parse(data: descriptorData)

            if json {
                print(JSONFormatter.formatReportDescriptor(
                    collections: descriptor.collections,
                    rawBytes: descriptor.rawBytes,
                    usageLookup: usageLookup
                ))
            } else {
                print(TextFormatter.formatReportDescriptor(
                    collections: descriptor.collections,
                    rawBytes: descriptor.rawBytes,
                    usageLookup: usageLookup
                ))
            }
        } catch let error as InspectHIDError {
            // Parse failure - show error with raw bytes fallback
            if json {
                print(JSONFormatter.formatDescriptorError(
                    reason: error.errorDescription ?? "Unknown error",
                    rawBytes: descriptorData
                ))
            } else {
                print(TextFormatter.formatDescriptorError(
                    reason: error.errorDescription ?? "Unknown error",
                    rawBytes: descriptorData
                ))
            }
            throw ExitCode(error.exitCode)
        }
    }

    private func printError(_ error: InspectHIDError) {
        FileHandle.standardError.write(
            Data((TextFormatter.formatError(error) + "\n").utf8)
        )
    }
}
