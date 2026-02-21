import Foundation

/// Error types for inspect-hid operations
public enum InspectHIDError: Error, LocalizedError, Equatable, Sendable {
    /// Device not found with the given specifier
    case deviceNotFound(specifier: String)

    /// Multiple devices match the given specifier
    case ambiguousDevice(count: Int)

    /// Invalid device specifier format
    case invalidDeviceSpecifier(input: String)

    /// Permission denied when accessing device
    case permissionDenied(device: String)

    /// Another process has exclusive access to the device
    case exclusiveAccess(device: String)

    /// Device was disconnected during operation
    case deviceDisconnected

    /// IOKit error with specific code
    case ioKitError(code: Int32)

    /// Report descriptor not available or failed to retrieve
    case reportDescriptorNotAvailable

    /// Failed to parse report descriptor
    case descriptorParseFailed(reason: String)

    public var errorDescription: String? {
        switch self {
        case .deviceNotFound(let specifier):
            return "Device not found: \(specifier)"
        case .ambiguousDevice(let count):
            return "Multiple devices (\(count)) match the specifier. Please be more specific."
        case .invalidDeviceSpecifier(let input):
            return "Invalid device specifier: '\(input)'. Use index number or VID:PID format."
        case .permissionDenied:
            return "Permission denied. Grant Input Monitoring access in System Settings > Privacy & Security."
        case .exclusiveAccess(let device):
            return "Cannot access \(device): another process has exclusive access, or Input Monitoring permission has not been granted."
        case .deviceDisconnected:
            return "Device was disconnected."
        case .ioKitError(let code):
            return "IOKit error: \(code)"
        case .reportDescriptorNotAvailable:
            return "Report descriptor not available for this device."
        case .descriptorParseFailed(let reason):
            return "Failed to parse descriptor: \(reason)"
        }
    }

    /// Exit code for this error type
    public var exitCode: Int32 {
        switch self {
        case .deviceNotFound, .invalidDeviceSpecifier, .ambiguousDevice:
            return 1
        case .permissionDenied, .exclusiveAccess:
            return 2
        case .deviceDisconnected:
            return 3
        case .ioKitError, .reportDescriptorNotAvailable, .descriptorParseFailed:
            return 1
        }
    }
}
