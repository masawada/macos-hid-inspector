import Foundation

/// Maps IOKit return codes to InspectHIDError
public struct IOKitErrorMapper {

    // MARK: - Common IOKit Return Codes

    /// kIOReturnSuccess
    public static let kIOReturnSuccess: Int32 = 0

    /// kIOReturnNotPermitted - permission error
    public static let kIOReturnNotPermitted: Int32 = -536870212

    /// kIOReturnNotPrivileged - privilege error
    public static let kIOReturnNotPrivileged: Int32 = -536870203

    /// kIOReturnBadArgument
    public static let kIOReturnBadArgument: Int32 = -536870220

    /// kIOReturnNoDevice
    public static let kIOReturnNoDevice: Int32 = -536870208

    /// kIOReturnNotAttached
    public static let kIOReturnNotAttached: Int32 = -536870206

    /// kIOReturnExclusiveAccess
    public static let kIOReturnExclusiveAccess: Int32 = -536870189

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
        case kIOReturnNotPermitted, kIOReturnNotPrivileged, kIOReturnExclusiveAccess:
            return .permissionDenied(device: device)
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
        case kIOReturnNotPermitted, kIOReturnNotPrivileged, kIOReturnExclusiveAccess:
            return true
        default:
            return false
        }
    }
}
