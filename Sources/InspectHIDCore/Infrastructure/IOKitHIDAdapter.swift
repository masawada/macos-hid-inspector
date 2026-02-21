import Foundation
import IOKit.hid

/// IOKit HID adapter for accessing USB HID devices
public final class IOKitHIDAdapter: IOKitHIDAdapterProtocol, @unchecked Sendable {

    // MARK: - Monitoring State

    private var inputReportBuffer = [UInt8](repeating: 0, count: 1024)
    private var inputReportCallbackWithId: ((Int, Data) -> Void)?
    private var removalCallback: (() -> Void)?
    private var currentRunLoop: CFRunLoop?

    public init() {}

    /// Enumerate all connected HID devices using IOHIDManager
    /// - Throws: InspectHIDError for permission or IOKit errors
    public func enumerateDevices() throws -> [any HIDDeviceHandle] {
        // Create HID Manager
        let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))

        // Set device matching to all HID devices
        IOHIDManagerSetDeviceMatching(manager, nil)

        // Copy devices
        guard let deviceSet = IOHIDManagerCopyDevices(manager) else {
            return []
        }

        // Sort devices by location ID to ensure consistent ordering across runs
        // (Set iteration order is non-deterministic)
        // A single physical device can expose multiple HID interfaces (e.g., keyboard + media keys)
        // sharing the same location/vendor/product IDs, so we also sort by usage page and usage
        // to guarantee a total order.
        guard let ioDevices = deviceSet as? Set<IOHIDDevice> else { return [] }
        let sortedDevices = ioDevices.sorted { device1, device2 in
            let locationId1 = getIntProperty(device1, key: kIOHIDLocationIDKey) ?? 0
            let locationId2 = getIntProperty(device2, key: kIOHIDLocationIDKey) ?? 0
            if locationId1 != locationId2 {
                return locationId1 < locationId2
            }
            let vendorId1 = getIntProperty(device1, key: kIOHIDVendorIDKey) ?? 0
            let vendorId2 = getIntProperty(device2, key: kIOHIDVendorIDKey) ?? 0
            if vendorId1 != vendorId2 {
                return vendorId1 < vendorId2
            }
            let productId1 = getIntProperty(device1, key: kIOHIDProductIDKey) ?? 0
            let productId2 = getIntProperty(device2, key: kIOHIDProductIDKey) ?? 0
            if productId1 != productId2 {
                return productId1 < productId2
            }
            // Break ties for multiple interfaces of the same physical device
            let usagePage1 = getIntProperty(device1, key: kIOHIDPrimaryUsagePageKey) ?? 0
            let usagePage2 = getIntProperty(device2, key: kIOHIDPrimaryUsagePageKey) ?? 0
            if usagePage1 != usagePage2 {
                return usagePage1 < usagePage2
            }
            let usage1 = getIntProperty(device1, key: kIOHIDPrimaryUsageKey) ?? 0
            let usage2 = getIntProperty(device2, key: kIOHIDPrimaryUsageKey) ?? 0
            return usage1 < usage2
        }

        let devices = sortedDevices.map { IOHIDDeviceHandle(device: $0) }
        return devices
    }

    /// Get Vendor ID from IOHIDDevice
    public func getVendorId(_ device: any HIDDeviceHandle) -> UInt16? {
        guard let ioDevice = (device as? IOHIDDeviceHandle)?.device else {
            return nil
        }
        return getIntProperty(ioDevice, key: kIOHIDVendorIDKey).map { UInt16($0) }
    }

    /// Get Product ID from IOHIDDevice
    public func getProductId(_ device: any HIDDeviceHandle) -> UInt16? {
        guard let ioDevice = (device as? IOHIDDeviceHandle)?.device else {
            return nil
        }
        return getIntProperty(ioDevice, key: kIOHIDProductIDKey).map { UInt16($0) }
    }

    /// Get Product Name from IOHIDDevice
    public func getProductName(_ device: any HIDDeviceHandle) -> String? {
        guard let ioDevice = (device as? IOHIDDeviceHandle)?.device else {
            return nil
        }
        return getStringProperty(ioDevice, key: kIOHIDProductKey)
    }

    /// Get Manufacturer from IOHIDDevice
    public func getManufacturer(_ device: any HIDDeviceHandle) -> String? {
        guard let ioDevice = (device as? IOHIDDeviceHandle)?.device else {
            return nil
        }
        return getStringProperty(ioDevice, key: kIOHIDManufacturerKey)
    }

    /// Get Serial Number from IOHIDDevice
    public func getSerialNumber(_ device: any HIDDeviceHandle) -> String? {
        guard let ioDevice = (device as? IOHIDDeviceHandle)?.device else {
            return nil
        }
        return getStringProperty(ioDevice, key: kIOHIDSerialNumberKey)
    }

    // MARK: - Device Descriptor Properties

    /// Get USB Device Class from IOHIDDevice
    /// Note: HID devices typically have device class 0 (defined at interface level)
    public func getDeviceClass(_ device: any HIDDeviceHandle) -> UInt8? {
        guard let ioDevice = (device as? IOHIDDeviceHandle)?.device else {
            return nil
        }
        return getIntProperty(ioDevice, key: kIOHIDDeviceUsagePageKey).map { UInt8(clamping: $0) }
    }

    /// Get USB Device Subclass from IOHIDDevice
    public func getDeviceSubClass(_ device: any HIDDeviceHandle) -> UInt8? {
        guard let ioDevice = (device as? IOHIDDeviceHandle)?.device else {
            return nil
        }
        return getIntProperty(ioDevice, key: kIOHIDDeviceUsageKey).map { UInt8(clamping: $0) }
    }

    /// Get USB Device Protocol from IOHIDDevice
    public func getDeviceProtocol(_ device: any HIDDeviceHandle) -> UInt8? {
        guard let ioDevice = (device as? IOHIDDeviceHandle)?.device else {
            return nil
        }
        // HID devices use primary usage page as protocol indicator
        return getIntProperty(ioDevice, key: kIOHIDPrimaryUsagePageKey).map { UInt8(clamping: $0) }
    }

    /// Get device version number from IOHIDDevice
    public func getVersionNumber(_ device: any HIDDeviceHandle) -> UInt16? {
        guard let ioDevice = (device as? IOHIDDeviceHandle)?.device else {
            return nil
        }
        return getIntProperty(ioDevice, key: kIOHIDVersionNumberKey).map { UInt16(clamping: $0) }
    }

    /// Get HID Report Descriptor from IOHIDDevice
    public func getReportDescriptor(_ device: any HIDDeviceHandle) -> Data? {
        guard let ioDevice = (device as? IOHIDDeviceHandle)?.device else {
            return nil
        }
        guard let value = IOHIDDeviceGetProperty(ioDevice, kIOHIDReportDescriptorKey as CFString) else {
            return nil
        }
        return value as? Data
    }

    // MARK: - Device Monitoring

    /// Open device for exclusive access (backwards compatibility)
    public func open(_ device: any HIDDeviceHandle) throws {
        try open(device, exclusive: true)
    }

    /// Open device with specified access mode
    /// - Parameters:
    ///   - device: Device to open
    ///   - exclusive: If true, seize device for exclusive access. If false, open in shared mode.
    public func open(_ device: any HIDDeviceHandle, exclusive: Bool) throws {
        guard let ioDevice = (device as? IOHIDDeviceHandle)?.device else {
            throw InspectHIDError.ioKitError(code: -1)
        }

        let options = exclusive ? IOOptionBits(kIOHIDOptionsTypeSeizeDevice) : IOOptionBits(kIOHIDOptionsTypeNone)
        let result = IOHIDDeviceOpen(ioDevice, options)
        guard result == kIOReturnSuccess else {
            throw IOKitErrorMapper.mapToInspectHIDError(code: result)
        }
    }

    /// Close device and release resources
    public func close(_ device: any HIDDeviceHandle) {
        guard let ioDevice = (device as? IOHIDDeviceHandle)?.device else {
            return
        }
        IOHIDDeviceClose(ioDevice, IOOptionBits(kIOHIDOptionsTypeNone))
        inputReportCallbackWithId = nil
        removalCallback = nil
    }

    /// Register callback for input reports with report ID
    public func registerInputReportCallbackWithId(_ device: any HIDDeviceHandle, callback: @escaping (Int, Data) -> Void) {
        guard let ioDevice = (device as? IOHIDDeviceHandle)?.device else {
            return
        }

        inputReportCallbackWithId = callback

        // Set up the input report callback using the C function pointer approach
        let bufferPtr = UnsafeMutablePointer<UInt8>.allocate(capacity: inputReportBuffer.count)
        bufferPtr.initialize(repeating: 0, count: inputReportBuffer.count)

        let context = Unmanaged.passUnretained(self).toOpaque()

        IOHIDDeviceRegisterInputReportCallback(
            ioDevice,
            bufferPtr,
            inputReportBuffer.count,
            { context, _, _, _, reportId, report, reportLength in
                guard let context = context else { return }
                let adapter = Unmanaged<IOKitHIDAdapter>.fromOpaque(context).takeUnretainedValue()

                let data = Data(bytes: report, count: reportLength)
                adapter.inputReportCallbackWithId?(Int(reportId), data)
            },
            context
        )

        // Schedule on current run loop
        IOHIDDeviceScheduleWithRunLoop(ioDevice, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
    }

    /// Register callback for device removal
    public func registerRemovalCallback(_ device: any HIDDeviceHandle, callback: @escaping () -> Void) {
        guard let ioDevice = (device as? IOHIDDeviceHandle)?.device else {
            return
        }

        removalCallback = callback

        let context = Unmanaged.passUnretained(self).toOpaque()

        IOHIDDeviceRegisterRemovalCallback(
            ioDevice,
            { context, _, _ in
                guard let context = context else { return }
                let adapter = Unmanaged<IOKitHIDAdapter>.fromOpaque(context).takeUnretainedValue()
                adapter.removalCallback?()
            },
            context
        )
    }

    /// Run the event loop for receiving reports
    public func runLoop() {
        currentRunLoop = CFRunLoopGetCurrent()
        CFRunLoopRun()
    }

    /// Stop the event loop
    public func stopRunLoop() {
        if let runLoop = currentRunLoop {
            CFRunLoopStop(runLoop)
        }
    }

    // MARK: - Private Helpers

    private func getIntProperty(_ device: IOHIDDevice, key: String) -> Int? {
        guard let value = IOHIDDeviceGetProperty(device, key as CFString) else {
            return nil
        }
        if let number = value as? NSNumber {
            return number.intValue
        }
        return nil
    }

    private func getStringProperty(_ device: IOHIDDevice, key: String) -> String? {
        guard let value = IOHIDDeviceGetProperty(device, key as CFString) else {
            return nil
        }
        return value as? String
    }
}
