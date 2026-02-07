import Foundation

/// Service for HID device operations
public final class HIDDeviceService: HIDDeviceServiceProtocol, @unchecked Sendable {
    private let adapter: any IOKitHIDAdapterProtocol

    // MARK: - Monitoring State
    private var currentMonitoringDevice: (any HIDDeviceHandle)?
    private var reportCallback: ((HIDReport) -> Void)?

    public init(adapter: any IOKitHIDAdapterProtocol = IOKitHIDAdapter()) {
        self.adapter = adapter
    }

    /// List all connected HID devices with their information
    public func listDevices() throws -> [HIDDeviceInfo] {
        let devices = try adapter.enumerateDevices()

        return devices.enumerated().map { index, device in
            HIDDeviceInfo(
                index: index,
                vendorId: adapter.getVendorId(device) ?? 0,
                productId: adapter.getProductId(device) ?? 0,
                productName: adapter.getProductName(device) ?? "",
                manufacturer: adapter.getManufacturer(device) ?? "",
                serialNumber: adapter.getSerialNumber(device) ?? ""
            )
        }
    }

    /// Get Device Descriptor for specified device
    public func getDeviceDescriptor(specifier: DeviceSpecifier) throws -> DeviceDescriptor {
        let devices = try adapter.enumerateDevices()
        let device = try resolveDevice(specifier: specifier, from: devices)

        let vendorId = adapter.getVendorId(device) ?? 0
        let productId = adapter.getProductId(device) ?? 0
        let versionNumber = adapter.getVersionNumber(device) ?? 0

        return DeviceDescriptor(
            bDeviceClass: adapter.getDeviceClass(device) ?? 0,
            bDeviceSubClass: adapter.getDeviceSubClass(device) ?? 0,
            bDeviceProtocol: adapter.getDeviceProtocol(device) ?? 0,
            idVendor: vendorId,
            idProduct: productId,
            bcdDevice: formatBcdVersion(versionNumber),
            iManufacturer: adapter.getManufacturer(device) ?? "",
            iProduct: adapter.getProductName(device) ?? "",
            iSerialNumber: adapter.getSerialNumber(device) ?? ""
        )
    }

    /// Get Report Descriptor raw bytes for specified device
    public func getReportDescriptor(specifier: DeviceSpecifier) throws -> Data {
        let devices = try adapter.enumerateDevices()
        let device = try resolveDevice(specifier: specifier, from: devices)

        guard let reportDescriptor = adapter.getReportDescriptor(device) else {
            throw InspectHIDError.reportDescriptorNotAvailable
        }

        return reportDescriptor
    }

    // MARK: - Private Helpers

    /// Resolve a device specifier to an actual device handle
    private func resolveDevice(specifier: DeviceSpecifier, from devices: [any HIDDeviceHandle]) throws -> any HIDDeviceHandle {
        switch specifier {
        case .index(let index):
            guard index >= 0 && index < devices.count else {
                throw InspectHIDError.deviceNotFound(specifier: "index \(index)")
            }
            return devices[index]

        case .vidPid(let vendorId, let productId):
            let matching = devices.filter { device in
                adapter.getVendorId(device) == vendorId && adapter.getProductId(device) == productId
            }

            guard !matching.isEmpty else {
                throw InspectHIDError.deviceNotFound(specifier: String(format: "%04X:%04X", vendorId, productId))
            }

            if matching.count > 1 {
                throw InspectHIDError.ambiguousDevice(count: matching.count)
            }

            return matching[0]
        }
    }

    /// Format BCD version number as string (e.g., 0x0210 -> "2.10")
    /// BCD format: upper byte is major version, lower byte is minor in BCD (e.g., 0x10 = 10)
    private func formatBcdVersion(_ version: UInt16) -> String {
        let major = (version >> 8) & 0xFF
        let minorBcd = version & 0xFF
        // Convert BCD minor to decimal: 0x10 -> 10, 0x21 -> 21
        let minorHigh = (minorBcd >> 4) & 0x0F
        let minorLow = minorBcd & 0x0F
        let minor = minorHigh * 10 + minorLow
        return String(format: "%d.%02d", major, minor)
    }

    // MARK: - Monitoring

    /// Start monitoring HID reports from specified device
    public func startMonitoring(specifier: DeviceSpecifier, onReport: @escaping (HIDReport) -> Void) throws {
        let devices = try adapter.enumerateDevices()
        let device = try resolveDevice(specifier: specifier, from: devices)

        currentMonitoringDevice = device
        reportCallback = onReport

        try adapter.open(device)

        adapter.registerInputReportCallbackWithId(device) { [weak self] reportId, data in
            guard let self = self, let callback = self.reportCallback else { return }

            let report = HIDReport(
                timestamp: Date(),
                data: data,
                reportId: reportId
            )
            callback(report)
        }
    }

    /// Stop monitoring and release resources
    public func stopMonitoring() {
        if let device = currentMonitoringDevice {
            adapter.close(device)
        }
        currentMonitoringDevice = nil
        reportCallback = nil
    }
}
