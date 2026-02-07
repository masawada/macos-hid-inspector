import Foundation

/// Protocol for HID device operations - Domain layer
public protocol HIDDeviceServiceProtocol: Sendable {
    /// List all connected HID devices
    func listDevices() throws -> [HIDDeviceInfo]

    /// Get Device Descriptor for specified device
    func getDeviceDescriptor(specifier: DeviceSpecifier) throws -> DeviceDescriptor

    /// Get Report Descriptor raw bytes for specified device
    func getReportDescriptor(specifier: DeviceSpecifier) throws -> Data

    // MARK: - Monitoring

    /// Start monitoring HID reports from specified device
    /// - Parameters:
    ///   - specifier: Device to monitor
    ///   - onReport: Callback called when a report is received
    func startMonitoring(specifier: DeviceSpecifier, onReport: @escaping (HIDReport) -> Void) throws

    /// Stop monitoring and release resources
    func stopMonitoring()
}
