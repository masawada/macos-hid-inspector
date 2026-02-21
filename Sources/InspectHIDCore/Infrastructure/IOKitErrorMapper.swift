import Foundation

/// Maps IOKit return codes to InspectHIDError
public struct IOKitErrorMapper {

    // MARK: - Common IOKit Return Codes
    // Values from IOKit/IOReturn.h: iokit_common_err(x) = 0xE0000000 | x

    /// kIOReturnSuccess
    public static let kIOReturnSuccess: Int32 = 0

    /// kIOReturnNoDevice - iokit_common_err(0x2c0)
    public static let kIOReturnNoDevice: Int32 = Int32(bitPattern: 0xE00002C0)

    /// kIOReturnNotPrivileged - iokit_common_err(0x2c1) - privilege violation
    public static let kIOReturnNotPrivileged: Int32 = Int32(bitPattern: 0xE00002C1)

    /// kIOReturnBadArgument - iokit_common_err(0x2c2)
    public static let kIOReturnBadArgument: Int32 = Int32(bitPattern: 0xE00002C2)

    /// kIOReturnExclusiveAccess - iokit_common_err(0x2c5)
    public static let kIOReturnExclusiveAccess: Int32 = Int32(bitPattern: 0xE00002C5)

    /// kIOReturnNotAttached - iokit_common_err(0x2d9)
    public static let kIOReturnNotAttached: Int32 = Int32(bitPattern: 0xE00002D9)

    /// kIOReturnNotPermitted - iokit_common_err(0x2e2)
    public static let kIOReturnNotPermitted: Int32 = Int32(bitPattern: 0xE00002E2)

    // MARK: - Mapping

    /// Maps an IOKit return code to an InspectHIDError
    /// - Parameter code: The IOKit return code
    /// - Returns: The corresponding InspectHIDError
    public static func mapToInspectHIDError(code: Int32) -> InspectHIDError {
        return mapToInspectHIDError(code: code, deviceName: nil)
    }

    /// Maps an IOKit return code to an InspectHIDError with device context
    /// - Parameters:
    ///   - code: The IOKit return code
    ///   - deviceName: Optional device name for context
    /// - Returns: The corresponding InspectHIDError
    public static func mapToInspectHIDError(code: Int32, deviceName: String?) -> InspectHIDError {
        let device = deviceName ?? "HID Device"

        switch code {
        case kIOReturnNotPermitted, kIOReturnNotPrivileged:
            return .permissionDenied(device: device)
        case kIOReturnExclusiveAccess:
            return .exclusiveAccess(device: device)
        case kIOReturnNoDevice, kIOReturnNotAttached:
            return .deviceDisconnected
        default:
            return .ioKitError(code: code)
        }
    }

    /// Checks if the given IOKit return code indicates success
    /// - Parameter code: The IOKit return code
    /// - Returns: true if the code indicates success
    public static func isSuccess(_ code: Int32) -> Bool {
        return code == kIOReturnSuccess
    }

    /// Checks if the given IOKit return code indicates a permission error
    /// - Parameter code: The IOKit return code
    /// - Returns: true if the code indicates a permission-related error
    public static func isPermissionError(_ code: Int32) -> Bool {
        switch code {
        case kIOReturnNotPermitted, kIOReturnNotPrivileged:
            return true
        default:
            return false
        }
    }

    /// Checks if the given IOKit return code indicates an exclusive access error
    /// - Parameter code: The IOKit return code
    /// - Returns: true if the code indicates an exclusive access error
    public static func isExclusiveAccessError(_ code: Int32) -> Bool {
        return code == kIOReturnExclusiveAccess
    }
}
