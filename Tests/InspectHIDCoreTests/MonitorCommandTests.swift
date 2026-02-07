import Foundation
import Testing
@testable import InspectHIDCore

/// Tests for MonitorCommand
@Suite("MonitorCommand Tests")
struct MonitorCommandTests {

    // MARK: - Test: Command structure and options

    @Test("MonitorCommand configuration has correct command name")
    func commandConfigurationCorrect() {
        let config = MonitorCommand.configuration
        #expect(config.commandName == "monitor")
    }

    @Test("MonitorCommand configuration has abstract")
    func commandConfigurationHasAbstract() {
        let config = MonitorCommand.configuration
        #expect(!config.abstract.isEmpty)
    }

    // MARK: - Test: Device specifier parsing

    @Test("Parses index device specifier")
    func parsesIndexSpecifier() throws {
        let selector = DeviceSelector()
        let specifier = try selector.parse(input: "0")

        if case .index(let index) = specifier {
            #expect(index == 0)
        } else {
            Issue.record("Expected index specifier")
        }
    }

    @Test("Parses VID:PID device specifier")
    func parsesVidPidSpecifier() throws {
        let selector = DeviceSelector()
        let specifier = try selector.parse(input: "1234:5678")

        if case .vidPid(let vid, let pid) = specifier {
            #expect(vid == 0x1234)
            #expect(pid == 0x5678)
        } else {
            Issue.record("Expected VID:PID specifier")
        }
    }

    // MARK: - Test: Text output formatting for reports

    @Test("TextFormatter formats HIDReport with timestamp and hex")
    func textFormatterFormatsReport() {
        let data = Data([0x01, 0x02, 0x03, 0xAB])
        let timestamp = Date()
        let report = HIDReport(timestamp: timestamp, data: data, reportId: 0)

        let output = TextFormatter.formatHIDReport(report)

        // Should contain hex representation
        #expect(output.contains("01 02 03 AB"))
        // Should contain timestamp format [HH:mm:ss.SSS]
        #expect(output.contains("["))
        #expect(output.contains("]"))
    }

    @Test("TextFormatter formats HIDReport with report ID")
    func textFormatterFormatsReportWithId() {
        let data = Data([0x05, 0x01, 0x02])
        let report = HIDReport(timestamp: Date(), data: data, reportId: 5)

        let output = TextFormatter.formatHIDReport(report)

        #expect(output.contains("Report ID 5"))
        #expect(output.contains("05 01 02"))
    }

    // MARK: - Test: JSON output formatting for reports

    @Test("JSONFormatter formats HIDReport correctly")
    func jsonFormatterFormatsReport() {
        let data = Data([0x01, 0x02, 0x03])
        let timestamp = Date()
        let report = HIDReport(timestamp: timestamp, data: data, reportId: 2)

        let output = JSONFormatter.formatHIDReport(report)

        // Should be valid JSON
        #expect(output.contains("\"timestamp\""))
        #expect(output.contains("\"reportId\""))
        #expect(output.contains("\"data\""))
        #expect(output.contains("\"reportId\":2"))
        #expect(output.contains("01 02 03"))
    }

    @Test("JSONFormatter formats report with ISO8601 timestamp")
    func jsonFormatterUsesISO8601Timestamp() {
        let data = Data([0x01])
        let timestamp = Date()
        let report = HIDReport(timestamp: timestamp, data: data, reportId: 0)

        let output = JSONFormatter.formatHIDReport(report)

        // ISO8601 format should contain T separator and Z or +00:00
        #expect(output.contains("T"))
    }

    // MARK: - Test: Device opening and monitoring start

    @Test("startMonitoring opens device and registers callback")
    func startMonitoringOpensDevice() throws {
        let device = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Test Device",
            manufacturer: "Test",
            serialNumber: nil
        )
        let adapter = MockIOKitHIDAdapter(devices: [device])
        let service = HIDDeviceService(adapter: adapter)

        try service.startMonitoring(specifier: .index(0)) { _ in }

        #expect(adapter.openedDevices.contains { $0 === device })
    }

    // MARK: - Test: Report reception displays correctly

    @Test("Received reports are passed to callback with correct data")
    func receivedReportsPassedToCallback() throws {
        let device = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Test Device",
            manufacturer: "Test",
            serialNumber: nil
        )
        let adapter = MockIOKitHIDAdapter(devices: [device])
        let service = HIDDeviceService(adapter: adapter)

        var receivedReport: HIDReport?
        try service.startMonitoring(specifier: .index(0)) { report in
            receivedReport = report
        }

        let testData = Data([0xAA, 0xBB, 0xCC])
        adapter.simulateInputReport(for: device, data: testData)

        #expect(receivedReport != nil)
        #expect(receivedReport?.data == testData)
    }

    // MARK: - Test: Device disconnect handling

    @Test("Disconnect callback is invoked when device is removed")
    func disconnectCallbackInvokedOnRemoval() throws {
        let device = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Test Device",
            manufacturer: "Test",
            serialNumber: nil
        )
        let adapter = MockIOKitHIDAdapter(devices: [device])
        let service = HIDDeviceService(adapter: adapter)

        var disconnectCalled = false
        try service.startMonitoring(
            specifier: .index(0),
            onReport: { _ in },
            onDisconnect: { disconnectCalled = true }
        )

        adapter.simulateDeviceRemoval(for: device)

        #expect(disconnectCalled)
    }

    // MARK: - Test: Signal handling integration

    @Test("stopRunLoop stops the event loop")
    func stopRunLoopStopsEventLoop() throws {
        let device = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Test Device",
            manufacturer: "Test",
            serialNumber: nil
        )
        let adapter = MockIOKitHIDAdapter(devices: [device])
        let service = HIDDeviceService(adapter: adapter)

        try service.startMonitoring(specifier: .index(0)) { _ in }

        service.stopRunLoop()

        #expect(adapter.stopRunLoopCalled)
    }

    // MARK: - Test: Error cases

    @Test("Throws error for non-existent device")
    func throwsErrorForNonExistentDevice() throws {
        let adapter = MockIOKitHIDAdapter(devices: [])
        let service = HIDDeviceService(adapter: adapter)

        #expect(throws: InspectHIDError.self) {
            try service.startMonitoring(specifier: .index(0)) { _ in }
        }
    }

    @Test("Throws error for invalid device specifier")
    func throwsErrorForInvalidSpecifier() throws {
        let selector = DeviceSelector()

        #expect(throws: InspectHIDError.self) {
            _ = try selector.parse(input: "invalid")
        }
    }

    // MARK: - Test: Continuous output

    @Test("Multiple reports are received in order")
    func multipleReportsReceivedInOrder() throws {
        let device = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Test Device",
            manufacturer: "Test",
            serialNumber: nil
        )
        let adapter = MockIOKitHIDAdapter(devices: [device])
        let service = HIDDeviceService(adapter: adapter)

        var reports: [HIDReport] = []
        try service.startMonitoring(specifier: .index(0)) { report in
            reports.append(report)
        }

        adapter.simulateInputReport(for: device, data: Data([0x01]))
        adapter.simulateInputReport(for: device, data: Data([0x02]))
        adapter.simulateInputReport(for: device, data: Data([0x03]))

        #expect(reports.count == 3)
        #expect(reports[0].data == Data([0x01]))
        #expect(reports[1].data == Data([0x02]))
        #expect(reports[2].data == Data([0x03]))
    }

    // MARK: - Test: Resource cleanup

    @Test("stopMonitoring closes device")
    func stopMonitoringClosesDevice() throws {
        let device = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Test Device",
            manufacturer: "Test",
            serialNumber: nil
        )
        let adapter = MockIOKitHIDAdapter(devices: [device])
        let service = HIDDeviceService(adapter: adapter)

        try service.startMonitoring(specifier: .index(0)) { _ in }
        #expect(adapter.openedDevices.contains { $0 === device })

        service.stopMonitoring()
        #expect(!adapter.openedDevices.contains { $0 === device })
    }

    @Test("No reports received after stopMonitoring")
    func noReportsAfterStopMonitoring() throws {
        let device = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Test Device",
            manufacturer: "Test",
            serialNumber: nil
        )
        let adapter = MockIOKitHIDAdapter(devices: [device])
        let service = HIDDeviceService(adapter: adapter)

        var reports: [HIDReport] = []
        try service.startMonitoring(specifier: .index(0)) { report in
            reports.append(report)
        }

        service.stopMonitoring()
        adapter.simulateInputReport(for: device, data: Data([0x01]))

        #expect(reports.isEmpty)
    }
}
