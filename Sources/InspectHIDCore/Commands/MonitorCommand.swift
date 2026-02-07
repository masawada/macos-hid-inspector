import ArgumentParser
import Foundation

/// Monitors and displays real-time HID reports from a specified device.
public struct MonitorCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "monitor",
        abstract: "Monitor HID reports from a device"
    )

    @Argument(help: "Device specifier (index or VID:PID)")
    public var device: String

    @Flag(name: .long, help: "Output in JSON format")
    public var json: Bool = false

    public init() {}

    public mutating func run() throws {
        let selector = DeviceSelector()
        let service = HIDDeviceService()

        // Parse device specifier
        let specifier: DeviceSpecifier
        do {
            specifier = try selector.parse(input: device)
        } catch let error as InspectHIDError {
            FileHandle.standardError.write(Data((TextFormatter.formatError(error) + "\n").utf8))
            throw ExitCode(error.exitCode)
        }

        let outputJson = json

        // Set up signal handler for Ctrl+C
        SignalHandler.shared.onInterrupt {
            service.stopRunLoop()
        }

        // Start monitoring
        do {
            try service.startMonitoring(
                specifier: specifier,
                onReport: { report in
                    let output: String
                    if outputJson {
                        output = JSONFormatter.formatHIDReport(report)
                    } else {
                        output = TextFormatter.formatHIDReport(report)
                    }
                    print(output)
                    fflush(stdout)
                },
                onDisconnect: {
                    let message = "Device disconnected."
                    if outputJson {
                        print("{\"event\":\"disconnected\",\"message\":\"\(message)\"}")
                    } else {
                        print(message)
                    }
                    service.stopRunLoop()
                }
            )

            // Run the event loop (blocks until stopped)
            service.runLoop()

            // Clean up after run loop exits
            service.stopMonitoring()
            SignalHandler.shared.unregister()

        } catch let error as InspectHIDError {
            SignalHandler.shared.unregister()
            FileHandle.standardError.write(Data((TextFormatter.formatError(error) + "\n").utf8))
            throw ExitCode(error.exitCode)
        }
    }
}
