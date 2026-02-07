import Foundation

/// Protocol for device specifier parsing and resolution
public protocol DeviceSelectorProtocol: Sendable {
    /// Parse a user input string into a DeviceSpecifier
    /// - Parameter input: User input (index number or VID:PID format)
    /// - Returns: Parsed DeviceSpecifier
    /// - Throws: InspectHIDError.invalidDeviceSpecifier if format is invalid
    func parse(input: String) throws -> DeviceSpecifier

    /// Resolve a device specifier to a specific device
    /// - Parameters:
    ///   - specifier: The device specifier to resolve
    ///   - devices: The list of available devices
    /// - Returns: The matching device
    /// - Throws: InspectHIDError.deviceNotFound if no device matches
    /// - Throws: InspectHIDError.ambiguousDevice if multiple devices match
    func resolve(specifier: DeviceSpecifier, from devices: [HIDDeviceInfo]) throws -> HIDDeviceInfo
}

/// Implementation of device specifier parser and resolver
public struct DeviceSelector: DeviceSelectorProtocol {
    public init() {}

    public func parse(input: String) throws -> DeviceSpecifier {
        let trimmed = input.trimmingCharacters(in: .whitespaces)

        guard !trimmed.isEmpty else {
            throw InspectHIDError.invalidDeviceSpecifier(input: input)
        }

        // Check for VID:PID format (contains colon)
        if trimmed.contains(":") {
            return try parseVidPid(trimmed, original: input)
        }

        // Try to parse as index (pure numeric)
        return try parseIndex(trimmed, original: input)
    }

    // MARK: - Private Methods

    private func parseIndex(_ input: String, original: String) throws -> DeviceSpecifier {
        // Must be all digits
        guard input.allSatisfy({ $0.isNumber }) else {
            throw InspectHIDError.invalidDeviceSpecifier(input: original)
        }

        guard let index = Int(input), index >= 0 else {
            throw InspectHIDError.invalidDeviceSpecifier(input: original)
        }

        return .index(index)
    }

    private func parseVidPid(_ input: String, original: String) throws -> DeviceSpecifier {
        let components = input.split(separator: ":", omittingEmptySubsequences: false)

        // Must have exactly two components
        guard components.count == 2 else {
            throw InspectHIDError.invalidDeviceSpecifier(input: original)
        }

        let vidString = String(components[0])
        let pidString = String(components[1])

        // Both must be non-empty
        guard !vidString.isEmpty, !pidString.isEmpty else {
            throw InspectHIDError.invalidDeviceSpecifier(input: original)
        }

        guard let vendorId = parseHexValue(vidString),
              let productId = parseHexValue(pidString) else {
            throw InspectHIDError.invalidDeviceSpecifier(input: original)
        }

        return .vidPid(vendorId: vendorId, productId: productId)
    }

    private func parseHexValue(_ input: String) -> UInt16? {
        var hexString = input

        // Remove optional 0x prefix
        if hexString.lowercased().hasPrefix("0x") {
            hexString = String(hexString.dropFirst(2))
        }

        // Must be valid hex characters
        guard hexString.allSatisfy({ $0.isHexDigit }) else {
            return nil
        }

        // Parse as hex and check range
        guard let value = UInt32(hexString, radix: 16),
              value <= UInt32(UInt16.max) else {
            return nil
        }

        return UInt16(value)
    }

    // MARK: - Device Resolution

    public func resolve(specifier: DeviceSpecifier, from devices: [HIDDeviceInfo]) throws -> HIDDeviceInfo {
        switch specifier {
        case .index(let index):
            return try resolveByIndex(index, from: devices)
        case .vidPid(let vendorId, let productId):
            return try resolveByVidPid(vendorId: vendorId, productId: productId, from: devices)
        }
    }

    private func resolveByIndex(_ index: Int, from devices: [HIDDeviceInfo]) throws -> HIDDeviceInfo {
        guard let device = devices.first(where: { $0.index == index }) else {
            throw InspectHIDError.deviceNotFound(specifier: "index \(index)")
        }
        return device
    }

    private func resolveByVidPid(vendorId: UInt16, productId: UInt16, from devices: [HIDDeviceInfo]) throws -> HIDDeviceInfo {
        let matches = devices.filter { $0.vendorId == vendorId && $0.productId == productId }

        if matches.isEmpty {
            let specifier = String(format: "%04X:%04X", vendorId, productId)
            throw InspectHIDError.deviceNotFound(specifier: specifier)
        }

        if matches.count > 1 {
            throw InspectHIDError.ambiguousDevice(count: matches.count)
        }

        return matches[0]
    }
}
