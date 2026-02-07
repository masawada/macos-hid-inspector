import Foundation

/// Protocol for Usage Table lookup operations
public protocol UsageTableLookupProtocol: Sendable {
    /// Look up the human-readable name for a Usage Page
    /// - Parameter page: The Usage Page ID
    /// - Returns: Human-readable page name, or hex string for unknown pages
    func lookupPageName(page: UInt16) -> String

    /// Look up the human-readable name for a Usage within a page
    /// - Parameters:
    ///   - page: The Usage Page ID
    ///   - usage: The Usage ID
    /// - Returns: Human-readable usage name, or hex string for unknown usages
    func lookupUsageName(page: UInt16, usage: UInt16) -> String
}

/// Implementation of Usage Table lookup based on HID Usage Tables 1.7
public struct UsageTableLookup: UsageTableLookupProtocol, Sendable {

    public init() {}

    // MARK: - UsageTableLookupProtocol

    public func lookupPageName(page: UInt16) -> String {
        if let name = Self.usagePageNames[page] {
            return name
        }
        return String(format: "0x%04X", page)
    }

    public func lookupUsageName(page: UInt16, usage: UInt16) -> String {
        // Special handling for Button page (0x09)
        if page == 0x09 {
            if usage == 0 {
                return "No Button Pressed"
            }
            return "Button \(usage)"
        }

        // Special handling for Ordinal page (0x0A)
        if page == 0x0A {
            if usage == 0 {
                return "Undefined"
            }
            return "Instance \(usage)"
        }

        // Special handling for Monitor Enumerated page (0x81)
        if page == 0x81 {
            if usage == 0 {
                return "Undefined"
            }
            return "Enum \(usage)"
        }

        // Look up in page-specific usage tables
        if let pageUsages = Self.allUsageTables[page], let name = pageUsages[usage] {
            return name
        }

        return String(format: "0x%04X", usage)
    }

    // MARK: - Usage Page Names (HID Usage Tables 1.7)

    static let usagePageNames: [UInt16: String] = [
        0x00: "Undefined",
        0x01: "Generic Desktop Page",
        0x02: "Simulation Controls",
        0x03: "VR Controls",
        0x04: "Sport Controls",
        0x05: "Game Controls",
        0x06: "Generic Device Controls",
        0x07: "Keyboard/Keypad",
        0x08: "LED",
        0x09: "Button",
        0x0A: "Ordinal",
        0x0B: "Telephony Device",
        0x0C: "Consumer",
        0x0D: "Digitizers",
        0x0E: "Haptics",
        0x0F: "Physical Input Device",
        0x10: "Unicode",
        0x11: "SoC",
        0x12: "Eye and Head Trackers",
        0x14: "Auxiliary Display",
        0x20: "Sensors",
        0x40: "Medical Instrument",
        0x41: "Braille Display",
        0x59: "Lighting And Illumination",
        0x80: "Monitor",
        0x81: "Monitor Enumerated",
        0x82: "VESA Virtual Controls",
        0x84: "Power",
        0x85: "Battery System",
        0x8C: "Barcode Scanner",
        0x8D: "Scales",
        0x8E: "Magnetic Stripe Reader",
        0x90: "Camera Control",
        0x91: "Arcade",
        0x92: "Gaming Device",
        0xF1D0: "FIDO Alliance",
    ]

    // MARK: - All Usage Tables by Page

    static let allUsageTables: [UInt16: [UInt16: String]] = [
        0x01: usagePage0x01,
        0x02: usagePage0x02,
        0x03: usagePage0x03,
        0x04: usagePage0x04,
        0x05: usagePage0x05,
        0x06: usagePage0x06,
        0x07: usagePage0x07,
        0x08: usagePage0x08,
        0x0B: usagePage0x0B,
        0x0C: usagePage0x0C,
        0x0D: usagePage0x0D,
        0x0E: usagePage0x0E,
        0x0F: usagePage0x0F,
        0x11: usagePage0x11,
        0x12: usagePage0x12,
        0x14: usagePage0x14,
        0x20: usagePage0x20,
        0x40: usagePage0x40,
        0x41: usagePage0x41,
        0x59: usagePage0x59,
        0x80: usagePage0x80,
        0x82: usagePage0x82,
        0x84: usagePage0x84,
        0x85: usagePage0x85,
        0x8C: usagePage0x8C,
        0x8D: usagePage0x8D,
        0x8E: usagePage0x8E,
        0x90: usagePage0x90,
        0x91: usagePage0x91,
        0xF1D0: usagePage0xF1D0,
    ]
}
