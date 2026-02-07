import Testing
import Foundation
@testable import InspectHIDCore

/// Tests for HIDDeviceInfo domain model
struct HIDDeviceInfoTests {

    // MARK: - Model Structure Tests

    @Test("HIDDeviceInfo can be initialized with all properties")
    func canInitializeWithAllProperties() {
        let info = HIDDeviceInfo(
            index: 0,
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Test Device",
            manufacturer: "Test Manufacturer",
            serialNumber: "SN123"
        )

        #expect(info.index == 0)
        #expect(info.vendorId == 0x1234)
        #expect(info.productId == 0x5678)
        #expect(info.productName == "Test Device")
        #expect(info.manufacturer == "Test Manufacturer")
        #expect(info.serialNumber == "SN123")
    }

    @Test("HIDDeviceInfo index is Int type")
    func indexIsIntType() {
        let info = HIDDeviceInfo(
            index: 42,
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "",
            manufacturer: "",
            serialNumber: ""
        )
        let _: Int = info.index
        #expect(info.index == 42)
    }

    @Test("HIDDeviceInfo vendorId is UInt16 type")
    func vendorIdIsUInt16Type() {
        let info = HIDDeviceInfo(
            index: 0,
            vendorId: 0xFFFF,
            productId: 0x0000,
            productName: "",
            manufacturer: "",
            serialNumber: ""
        )
        let _: UInt16 = info.vendorId
        #expect(info.vendorId == 0xFFFF)
    }

    @Test("HIDDeviceInfo productId is UInt16 type")
    func productIdIsUInt16Type() {
        let info = HIDDeviceInfo(
            index: 0,
            vendorId: 0x0000,
            productId: 0xFFFF,
            productName: "",
            manufacturer: "",
            serialNumber: ""
        )
        let _: UInt16 = info.productId
        #expect(info.productId == 0xFFFF)
    }

    @Test("HIDDeviceInfo is Equatable")
    func isEquatable() {
        let info1 = HIDDeviceInfo(
            index: 0,
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Device",
            manufacturer: "Manufacturer",
            serialNumber: "SN001"
        )
        let info2 = HIDDeviceInfo(
            index: 0,
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Device",
            manufacturer: "Manufacturer",
            serialNumber: "SN001"
        )
        #expect(info1 == info2)
    }

    @Test("HIDDeviceInfo Equatable detects differences")
    func equatableDetectsDifferences() {
        let info1 = HIDDeviceInfo(
            index: 0,
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Device",
            manufacturer: "Manufacturer",
            serialNumber: "SN001"
        )
        let info2 = HIDDeviceInfo(
            index: 1,
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Device",
            manufacturer: "Manufacturer",
            serialNumber: "SN001"
        )
        #expect(info1 != info2)
    }

    // MARK: - Codable Tests for JSON Output

    @Test("HIDDeviceInfo is Codable for JSON output")
    func isCodable() throws {
        let info = HIDDeviceInfo(
            index: 0,
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Test Device",
            manufacturer: "Test Manufacturer",
            serialNumber: "SN123"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(info)
        #expect(!data.isEmpty)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(HIDDeviceInfo.self, from: data)
        #expect(decoded == info)
    }
}
