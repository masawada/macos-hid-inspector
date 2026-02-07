import Foundation
import Testing
@testable import InspectHIDCore

/// Tests for HID Report monitoring functionality
@Suite("HID Monitoring Tests")
struct HIDMonitoringTests {

    // MARK: - Test: Protocol defines monitoring methods

    @Test("IOKitHIDAdapterProtocol includes monitoring methods")
    func protocolIncludesMonitoringMethods() {
        // Verify the protocol has the required monitoring methods by creating a mock
        let adapter = MockIOKitHIDAdapter(devices: [])

        // These should compile if the protocol is correctly defined
        _ = adapter as any IOKitHIDAdapterProtocol
    }

    // MARK: - Test: Device can be opened for monitoring

    @Test("Opens device for monitoring")
    func opensDeviceForMonitoring() throws {
        let device = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Test Device",
            manufacturer: "Test",
            serialNumber: nil
        )
        let adapter = MockIOKitHIDAdapter(devices: [device])

        try adapter.open(device)

        #expect(adapter.openedDevices.contains { $0 === device })
    }

    // MARK: - Test: Device can be closed

    @Test("Closes device after monitoring")
    func closesDeviceAfterMonitoring() throws {
        let device = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Test Device",
            manufacturer: "Test",
            serialNumber: nil
        )
        let adapter = MockIOKitHIDAdapter(devices: [device])

        try adapter.open(device)
        adapter.close(device)

        #expect(!adapter.openedDevices.contains { $0 === device })
    }

    // MARK: - Test: Input report callback receives data

    @Test("Input report callback receives report data")
    func inputReportCallbackReceivesData() throws {
        let device = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Test Device",
            manufacturer: "Test",
            serialNumber: nil
        )
        let adapter = MockIOKitHIDAdapter(devices: [device])

        var receivedReports: [Data] = []

        try adapter.open(device)
        adapter.registerInputReportCallbackWithId(device) { _, data in
            receivedReports.append(data)
        }

        // Simulate receiving a report
        let testData = Data([0x01, 0x02, 0x03, 0x04])
        adapter.simulateInputReport(for: device, data: testData)

        #expect(receivedReports.count == 1)
        #expect(receivedReports[0] == testData)
    }

    // MARK: - Test: Multiple reports can be received

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

        var receivedReports: [Data] = []

        try adapter.open(device)
        adapter.registerInputReportCallbackWithId(device) { _, data in
            receivedReports.append(data)
        }

        // Simulate multiple reports
        let report1 = Data([0x01, 0x00])
        let report2 = Data([0x02, 0x00])
        let report3 = Data([0x03, 0x00])

        adapter.simulateInputReport(for: device, data: report1)
        adapter.simulateInputReport(for: device, data: report2)
        adapter.simulateInputReport(for: device, data: report3)

        #expect(receivedReports.count == 3)
        #expect(receivedReports[0] == report1)
        #expect(receivedReports[1] == report2)
        #expect(receivedReports[2] == report3)
    }

    // MARK: - Test: HIDDeviceService can start monitoring

    @Test("HIDDeviceService starts monitoring and receives reports")
    func deviceServiceStartsMonitoring() throws {
        let device = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Test Device",
            manufacturer: "Test",
            serialNumber: nil
        )
        let adapter = MockIOKitHIDAdapter(devices: [device])
        let service = HIDDeviceService(adapter: adapter)

        var receivedReports: [HIDReport] = []

        try service.startMonitoring(specifier: .index(0)) { report in
            receivedReports.append(report)
        }

        // Simulate receiving a report
        let testData = Data([0x01, 0x02, 0x03, 0x04])
        adapter.simulateInputReport(for: device, data: testData)

        #expect(receivedReports.count == 1)
        #expect(receivedReports[0].data == testData)
        #expect(receivedReports[0].reportId == 0)
    }

    // MARK: - Test: HIDDeviceService stops monitoring

    @Test("HIDDeviceService stops monitoring correctly")
    func deviceServiceStopsMonitoring() throws {
        let device = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Test Device",
            manufacturer: "Test",
            serialNumber: nil
        )
        let adapter = MockIOKitHIDAdapter(devices: [device])
        let service = HIDDeviceService(adapter: adapter)

        var receivedReports: [HIDReport] = []

        try service.startMonitoring(specifier: .index(0)) { report in
            receivedReports.append(report)
        }

        service.stopMonitoring()

        // Simulate a report after stopping - should not be received
        let testData = Data([0x01, 0x02, 0x03, 0x04])
        adapter.simulateInputReport(for: device, data: testData)

        #expect(receivedReports.isEmpty)
    }

    // MARK: - Test: Report includes timestamp

    @Test("HIDReport includes timestamp when received")
    func reportIncludesTimestamp() throws {
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
        let beforeTime = Date()

        try service.startMonitoring(specifier: .index(0)) { report in
            receivedReport = report
        }

        let testData = Data([0x01, 0x02])
        adapter.simulateInputReport(for: device, data: testData)

        let afterTime = Date()

        #expect(receivedReport != nil)
        #expect(receivedReport!.timestamp >= beforeTime)
        #expect(receivedReport!.timestamp <= afterTime)
    }

    // MARK: - Test: Report ID extraction

    @Test("Report ID extracted from first byte when applicable")
    func reportIdExtracted() throws {
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

        // Report with ID = 0x05
        let testData = Data([0x05, 0x01, 0x02])
        adapter.simulateInputReportWithId(for: device, reportId: 0x05, data: testData)

        #expect(receivedReport != nil)
        #expect(receivedReport!.reportId == 5)
    }

    // MARK: - Test: Device not found error

    @Test("Throws error when monitoring non-existent device")
    func throwsErrorForNonExistentDevice() throws {
        let adapter = MockIOKitHIDAdapter(devices: [])
        let service = HIDDeviceService(adapter: adapter)

        #expect(throws: InspectHIDError.self) {
            try service.startMonitoring(specifier: .index(0)) { _ in }
        }
    }
}
