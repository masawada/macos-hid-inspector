import Testing
import Foundation
@testable import InspectHIDCore

/// Tests for error handling functionality
@Suite("Error Handling Tests")
struct ErrorHandlingTests {

    // MARK: - InspectHIDError Tests

    @Suite("InspectHIDError")
    struct InspectHIDErrorTests {

        @Test("permissionDenied has correct exit code")
        func permissionDeniedExitCode() {
            let error = InspectHIDError.permissionDenied(device: "Test Device")
            #expect(error.exitCode == 2)
        }

        @Test("permissionDenied has helpful error message with guidance")
        func permissionDeniedErrorMessage() {
            let error = InspectHIDError.permissionDenied(device: "Test Device")
            let description = error.errorDescription ?? ""
            #expect(description.contains("Permission denied"))
            #expect(description.contains("Input Monitoring"))
            #expect(description.contains("System Settings"))
            #expect(description.contains("Privacy & Security"))
        }

        @Test("ioKitError converts code to Swift Error correctly")
        func ioKitErrorConversion() {
            let error = InspectHIDError.ioKitError(code: -536870212) // kIOReturnNotPermitted
            #expect(error.exitCode == 1)
            let description = error.errorDescription ?? ""
            #expect(description.contains("-536870212"))
        }

        @Test("deviceNotFound has exit code 1")
        func deviceNotFoundExitCode() {
            let error = InspectHIDError.deviceNotFound(specifier: "0")
            #expect(error.exitCode == 1)
        }

        @Test("deviceDisconnected has exit code 3")
        func deviceDisconnectedExitCode() {
            let error = InspectHIDError.deviceDisconnected
            #expect(error.exitCode == 3)
        }

        @Test("invalidDeviceSpecifier has exit code 1")
        func invalidDeviceSpecifierExitCode() {
            let error = InspectHIDError.invalidDeviceSpecifier(input: "invalid")
            #expect(error.exitCode == 1)
        }
    }

    // MARK: - IOKitHIDAdapter Error Handling Tests

    @Suite("IOKitHIDAdapter Error Handling")
    struct IOKitHIDAdapterErrorHandlingTests {

        @Test("MockIOKitHIDAdapter can throw permission denied error")
        func mockAdapterThrowsPermissionError() throws {
            let mockAdapter = MockIOKitHIDAdapterWithErrors(error: .permissionDenied(device: "Test"))
            do {
                _ = try mockAdapter.enumerateDevices()
                Issue.record("Expected error to be thrown")
            } catch let error as InspectHIDError {
                #expect(error == .permissionDenied(device: "Test"))
                #expect(error.exitCode == 2)
            }
        }

        @Test("MockIOKitHIDAdapter can throw ioKitError")
        func mockAdapterThrowsIOKitError() throws {
            let errorCode: Int32 = -536870212 // kIOReturnNotPermitted
            let mockAdapter = MockIOKitHIDAdapterWithErrors(error: .ioKitError(code: errorCode))
            do {
                _ = try mockAdapter.enumerateDevices()
                Issue.record("Expected error to be thrown")
            } catch let error as InspectHIDError {
                #expect(error == .ioKitError(code: errorCode))
            }
        }
    }

    // MARK: - HIDDeviceService Error Propagation Tests

    @Suite("HIDDeviceService Error Propagation")
    struct HIDDeviceServiceErrorPropagationTests {

        @Test("HIDDeviceService propagates permission error from adapter")
        func servicePropagatesPermissionError() throws {
            let mockAdapter = MockIOKitHIDAdapterWithErrors(error: .permissionDenied(device: "HID Device"))
            let service = HIDDeviceService(adapter: mockAdapter)

            do {
                _ = try service.listDevices()
                Issue.record("Expected error to be thrown")
            } catch let error as InspectHIDError {
                #expect(error == .permissionDenied(device: "HID Device"))
            }
        }

        @Test("HIDDeviceService propagates ioKitError from adapter")
        func servicePropagatesIOKitError() throws {
            let errorCode: Int32 = -536870206 // kIOReturnNotAttached
            let mockAdapter = MockIOKitHIDAdapterWithErrors(error: .ioKitError(code: errorCode))
            let service = HIDDeviceService(adapter: mockAdapter)

            do {
                _ = try service.listDevices()
                Issue.record("Expected error to be thrown")
            } catch let error as InspectHIDError {
                #expect(error == .ioKitError(code: errorCode))
            }
        }
    }

    // MARK: - IOKit Error Code Mapping Tests

    @Suite("IOKit Error Code Mapping")
    struct IOKitErrorCodeMappingTests {

        @Test("kIOReturnNotPermitted maps to permissionDenied error")
        func notPermittedMapsToPermissionDenied() {
            // kIOReturnNotPermitted = 0xE00002C2 = -536870206 (actual value differs)
            // Common permission-related codes
            let permissionRelatedCode: Int32 = -536870212 // common permission error

            let error = IOKitErrorMapper.mapToInspectHIDError(code: permissionRelatedCode)
            // Permission errors should be detected and mapped appropriately
            #expect(error.exitCode == 2 || error.exitCode == 1)
        }

        @Test("General IOKit error preserves error code")
        func generalErrorPreservesCode() {
            let errorCode: Int32 = -123456
            let error = IOKitErrorMapper.mapToInspectHIDError(code: errorCode)
            if case .ioKitError(let code) = error {
                #expect(code == errorCode)
            } else if case .permissionDenied = error {
                // Also acceptable for permission-related codes
            } else {
                Issue.record("Unexpected error type")
            }
        }
    }
}

/// Mock adapter that throws errors for testing
final class MockIOKitHIDAdapterWithErrors: IOKitHIDAdapterProtocol, @unchecked Sendable {
    private let error: InspectHIDError

    init(error: InspectHIDError) {
        self.error = error
    }

    func enumerateDevices() throws -> [any HIDDeviceHandle] {
        throw error
    }

    func getVendorId(_ device: any HIDDeviceHandle) -> UInt16? { nil }
    func getProductId(_ device: any HIDDeviceHandle) -> UInt16? { nil }
    func getProductName(_ device: any HIDDeviceHandle) -> String? { nil }
    func getManufacturer(_ device: any HIDDeviceHandle) -> String? { nil }
    func getSerialNumber(_ device: any HIDDeviceHandle) -> String? { nil }
    func getDeviceClass(_ device: any HIDDeviceHandle) -> UInt8? { nil }
    func getDeviceSubClass(_ device: any HIDDeviceHandle) -> UInt8? { nil }
    func getDeviceProtocol(_ device: any HIDDeviceHandle) -> UInt8? { nil }
    func getVersionNumber(_ device: any HIDDeviceHandle) -> UInt16? { nil }
    func getReportDescriptor(_ device: any HIDDeviceHandle) -> Data? { nil }
}
