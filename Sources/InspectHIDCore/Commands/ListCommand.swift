import ArgumentParser

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
        print("list command executed (stub)")
    }
}
