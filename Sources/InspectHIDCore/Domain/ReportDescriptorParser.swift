import Foundation

/// Protocol for Report Descriptor parsing operations
public protocol ReportDescriptorParserProtocol: Sendable {
    /// Parse HID Report Descriptor bytes into a structured format
    /// - Parameter data: Raw descriptor bytes
    /// - Returns: Parsed ReportDescriptor with items and collection tree
    /// - Throws: InspectHIDError.descriptorParseFailed if parsing fails
    func parse(data: Data) throws -> ReportDescriptor
}

/// Implementation of HID Report Descriptor parser
public struct ReportDescriptorParser: ReportDescriptorParserProtocol, Sendable {

    public init() {}

    // MARK: - ReportDescriptorParserProtocol

    public func parse(data: Data) throws -> ReportDescriptor {
        guard !data.isEmpty else {
            return ReportDescriptor(rawBytes: data, items: [], collections: [])
        }

        var items: [ReportDescriptorItem] = []
        var index = 0

        while index < data.count {
            do {
                let (item, bytesConsumed) = try parseItem(data: data, at: index)
                items.append(item)
                index += bytesConsumed
            } catch {
                // Fallback: include raw bytes information in error
                throw InspectHIDError.descriptorParseFailed(
                    reason: "Parse error at byte \(index): \(error.localizedDescription)"
                )
            }
        }

        // Build collection tree
        let collections = buildCollectionTree(items: items)

        return ReportDescriptor(rawBytes: data, items: items, collections: collections)
    }

    // MARK: - Private Parsing Methods

    private func parseItem(data: Data, at index: Int) throws -> (ReportDescriptorItem, Int) {
        let prefix = data[index]

        // Check for long item format (0xFE)
        if prefix == 0xFE {
            return try parseLongItem(data: data, at: index)
        }

        // Short item format
        return try parseShortItem(data: data, at: index)
    }

    private func parseShortItem(data: Data, at index: Int) throws -> (ReportDescriptorItem, Int) {
        let prefix = data[index]

        // Size is encoded in bits 0-1
        let bSize = prefix & 0x03
        let size: Int
        switch bSize {
        case 0: size = 0
        case 1: size = 1
        case 2: size = 2
        case 3: size = 4
        default: size = 0
        }

        // Type is encoded in bits 2-3
        let bType = (prefix >> 2) & 0x03

        // Tag is encoded in bits 4-7
        let bTag = (prefix >> 4) & 0x0F

        // Verify we have enough data
        guard index + 1 + size <= data.count else {
            throw InspectHIDError.descriptorParseFailed(
                reason: "Truncated item at offset \(index): expected \(size) bytes"
            )
        }

        // Read value
        let valueData = size > 0 ? data.subdata(in: (index + 1)..<(index + 1 + size)) : Data()

        let item = decodeItem(type: bType, tag: bTag, data: valueData)
        return (item, 1 + size)
    }

    private func parseLongItem(data: Data, at index: Int) throws -> (ReportDescriptorItem, Int) {
        // Long item: prefix(1) + bDataSize(1) + bLongItemTag(1) + data(bDataSize)
        guard index + 2 < data.count else {
            throw InspectHIDError.descriptorParseFailed(
                reason: "Truncated long item at offset \(index)"
            )
        }

        let dataSize = Int(data[index + 1])
        let longTag = data[index + 2]

        guard index + 3 + dataSize <= data.count else {
            throw InspectHIDError.descriptorParseFailed(
                reason: "Truncated long item data at offset \(index)"
            )
        }

        let itemData = data.subdata(in: (index + 3)..<(index + 3 + dataSize))
        return (.unknown(tag: longTag, data: itemData), 3 + dataSize)
    }

    private func decodeItem(type: UInt8, tag: UInt8, data: Data) -> ReportDescriptorItem {
        switch type {
        case 0: // Main
            return decodeMainItem(tag: tag, data: data)
        case 1: // Global
            return decodeGlobalItem(tag: tag, data: data)
        case 2: // Local
            return decodeLocalItem(tag: tag, data: data)
        default: // Reserved
            return .unknown(tag: (type << 4) | tag, data: data)
        }
    }

    private func decodeMainItem(tag: UInt8, data: Data) -> ReportDescriptorItem {
        let value = unsignedValue(from: data)

        switch tag {
        case 0x08: // Input
            return .input(value)
        case 0x09: // Output
            return .output(value)
        case 0x0B: // Feature
            return .feature(value)
        case 0x0A: // Collection
            let collectionType = CollectionType(rawValue: UInt8(value & 0xFF)) ?? .physical
            return .collection(collectionType)
        case 0x0C: // End Collection
            return .endCollection
        default:
            return .unknown(tag: tag, data: data)
        }
    }

    private func decodeGlobalItem(tag: UInt8, data: Data) -> ReportDescriptorItem {
        switch tag {
        case 0x00: // Usage Page
            return .usagePage(UInt16(unsignedValue(from: data) & 0xFFFF))
        case 0x01: // Logical Minimum
            return .logicalMinimum(signedValue(from: data))
        case 0x02: // Logical Maximum
            return .logicalMaximum(signedValue(from: data))
        case 0x03: // Physical Minimum
            return .physicalMinimum(signedValue(from: data))
        case 0x04: // Physical Maximum
            return .physicalMaximum(signedValue(from: data))
        case 0x05: // Unit Exponent
            return .unitExponent(signedValue(from: data))
        case 0x06: // Unit
            return .unit(unsignedValue(from: data))
        case 0x07: // Report Size
            return .reportSize(unsignedValue(from: data))
        case 0x08: // Report ID
            return .reportId(UInt8(unsignedValue(from: data) & 0xFF))
        case 0x09: // Report Count
            return .reportCount(unsignedValue(from: data))
        case 0x0A: // Push
            return .push
        case 0x0B: // Pop
            return .pop
        default:
            return .unknown(tag: tag, data: data)
        }
    }

    private func decodeLocalItem(tag: UInt8, data: Data) -> ReportDescriptorItem {
        let value = unsignedValue(from: data)

        switch tag {
        case 0x00: // Usage
            return .usage(value)
        case 0x01: // Usage Minimum
            return .usageMinimum(value)
        case 0x02: // Usage Maximum
            return .usageMaximum(value)
        case 0x03: // Designator Index
            return .designatorIndex(value)
        case 0x04: // Designator Minimum
            return .designatorMinimum(value)
        case 0x05: // Designator Maximum
            return .designatorMaximum(value)
        case 0x07: // String Index
            return .stringIndex(value)
        case 0x08: // String Minimum
            return .stringMinimum(value)
        case 0x09: // String Maximum
            return .stringMaximum(value)
        case 0x0A: // Delimiter
            return .delimiter(value)
        default:
            return .unknown(tag: tag, data: data)
        }
    }

    // MARK: - Value Extraction

    private func unsignedValue(from data: Data) -> UInt32 {
        guard !data.isEmpty else { return 0 }

        var value: UInt32 = 0
        for (i, byte) in data.enumerated() {
            value |= UInt32(byte) << (i * 8)
        }
        return value
    }

    private func signedValue(from data: Data) -> Int32 {
        guard !data.isEmpty else { return 0 }

        let unsigned = unsignedValue(from: data)

        // Sign extend based on actual data size
        switch data.count {
        case 1:
            let signed = Int8(bitPattern: UInt8(unsigned & 0xFF))
            return Int32(signed)
        case 2:
            let signed = Int16(bitPattern: UInt16(unsigned & 0xFFFF))
            return Int32(signed)
        case 4:
            return Int32(bitPattern: unsigned)
        default:
            return Int32(bitPattern: unsigned)
        }
    }

    // MARK: - Collection Tree Building

    private func buildCollectionTree(items: [ReportDescriptorItem]) -> [CollectionNode] {
        var rootCollections: [CollectionNode] = []
        var collectionStack: [CollectionNode] = []
        var currentUsagePage: UInt16 = 0
        var currentUsage: UInt32 = 0

        for item in items {
            switch item {
            case .usagePage(let page):
                currentUsagePage = page
            case .usage(let usage):
                currentUsage = usage
            case .collection(let type):
                let node = CollectionNode(
                    usagePage: currentUsagePage,
                    usage: currentUsage,
                    type: type
                )
                collectionStack.append(node)
                currentUsage = 0 // Reset usage for next item
            case .endCollection:
                if let completedNode = collectionStack.popLast() {
                    if collectionStack.isEmpty {
                        rootCollections.append(completedNode)
                    } else {
                        collectionStack[collectionStack.count - 1].children.append(completedNode)
                    }
                }
            default:
                // Add other items to current collection if any
                if !collectionStack.isEmpty {
                    collectionStack[collectionStack.count - 1].items.append(item)
                }
            }
        }

        // Handle unclosed collections (error case, but be permissive)
        while let unclosed = collectionStack.popLast() {
            if collectionStack.isEmpty {
                rootCollections.append(unclosed)
            } else {
                collectionStack[collectionStack.count - 1].children.append(unclosed)
            }
        }

        return rootCollections
    }
}
