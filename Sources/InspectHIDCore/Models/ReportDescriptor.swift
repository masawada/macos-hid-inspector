import Foundation

/// HID Report Descriptor collection type
public enum CollectionType: UInt8, Sendable, Codable {
    case physical = 0x00
    case application = 0x01
    case logical = 0x02
    case report = 0x03
    case namedArray = 0x04
    case usageSwitch = 0x05
    case usageModifier = 0x06

    /// Returns the name of the collection type
    public var name: String {
        switch self {
        case .physical: return "Physical"
        case .application: return "Application"
        case .logical: return "Logical"
        case .report: return "Report"
        case .namedArray: return "Named Array"
        case .usageSwitch: return "Usage Switch"
        case .usageModifier: return "Usage Modifier"
        }
    }
}

/// HID Report Descriptor item types
public enum ReportDescriptorItem: Sendable, Equatable {
    // Main items
    case input(UInt32)
    case output(UInt32)
    case feature(UInt32)
    case collection(CollectionType)
    case endCollection

    // Global items
    case usagePage(UInt16)
    case logicalMinimum(Int32)
    case logicalMaximum(Int32)
    case physicalMinimum(Int32)
    case physicalMaximum(Int32)
    case unitExponent(Int32)
    case unit(UInt32)
    case reportSize(UInt32)
    case reportId(UInt8)
    case reportCount(UInt32)
    case push
    case pop

    // Local items
    case usage(UInt32)
    case usageMinimum(UInt32)
    case usageMaximum(UInt32)
    case designatorIndex(UInt32)
    case designatorMinimum(UInt32)
    case designatorMaximum(UInt32)
    case stringIndex(UInt32)
    case stringMinimum(UInt32)
    case stringMaximum(UInt32)
    case delimiter(UInt32)

    // Unknown/reserved
    case unknown(tag: UInt8, data: Data)
}

/// A node in the HID Report Descriptor collection hierarchy
public struct CollectionNode: Sendable {
    public let usagePage: UInt16
    public let usage: UInt32
    public let type: CollectionType
    public var children: [CollectionNode]
    public var items: [ReportDescriptorItem]

    public init(
        usagePage: UInt16,
        usage: UInt32,
        type: CollectionType,
        children: [CollectionNode] = [],
        items: [ReportDescriptorItem] = []
    ) {
        self.usagePage = usagePage
        self.usage = usage
        self.type = type
        self.children = children
        self.items = items
    }
}

/// Parsed HID Report Descriptor
public struct ReportDescriptor: Sendable {
    /// The raw bytes of the descriptor
    public let rawBytes: Data

    /// All parsed items in order
    public let items: [ReportDescriptorItem]

    /// The collection tree structure
    public let collections: [CollectionNode]

    public init(
        rawBytes: Data,
        items: [ReportDescriptorItem] = [],
        collections: [CollectionNode] = []
    ) {
        self.rawBytes = rawBytes
        self.items = items
        self.collections = collections
    }
}
