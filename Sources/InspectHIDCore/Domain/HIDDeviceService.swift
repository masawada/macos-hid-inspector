import Foundation

/// Service for HID device operations
public final class HIDDeviceService: HIDDeviceServiceProtocol, @unchecked Sendable {
    private let adapter: any IOKitHIDAdapterProtocol

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
}
