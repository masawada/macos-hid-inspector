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
            let error = InspectHIDError.ioKitError(code: -12345)
            #expect(error.exitCode == 1)
            let description = error.errorDescription ?? ""
            #expect(description.contains("-12345"))
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

        @Test("deviceNotFound error includes specifier in message")
        func deviceNotFoundIncludesSpecifier() {
            let error = InspectHIDError.deviceNotFound(specifier: "0")
            let description = error.errorDescription ?? ""
            #expect(description.contains("0"), "Error message should include the specifier")
        }

        @Test("ambiguousDevice error includes count in message")
        func ambiguousDeviceIncludesCount() {
            let error = InspectHIDError.ambiguousDevice(count: 3)
            let description = error.errorDescription ?? ""
            #expect(description.contains("3"), "Should include device count")
            #expect(description.contains("Multiple"), "Should mention multiple devices")
        }

        @Test("reportDescriptorNotAvailable has exit code 1")
        func reportDescriptorNotAvailableExitCode() {
            let error = InspectHIDError.reportDescriptorNotAvailable
            #expect(error.exitCode == 1)
        }

        @Test("descriptorParseFailed has exit code 1")
        func descriptorParseFailedExitCode() {
            let error = InspectHIDError.descriptorParseFailed(reason: "Invalid format")
            #expect(error.exitCode == 1)
        }

        @Test("descriptorParseFailed includes reason in message")
        func descriptorParseFailedIncludesReason() {
            let reason = "Unexpected tag at offset 5"
            let error = InspectHIDError.descriptorParseFailed(reason: reason)
            let description = error.errorDescription ?? ""
            #expect(description.contains(reason), "Should include reason in message")
        }

        @Test("All error types have appropriate exit codes")
        func allErrorTypesHaveExitCodes() {
            #expect(InspectHIDError.deviceNotFound(specifier: "0").exitCode == 1)
            #expect(InspectHIDError.invalidDeviceSpecifier(input: "bad").exitCode == 1)
            #expect(InspectHIDError.ambiguousDevice(count: 2).exitCode == 1)
            #expect(InspectHIDError.permissionDenied(device: "test").exitCode == 2)
            #expect(InspectHIDError.deviceDisconnected.exitCode == 3)
            #expect(InspectHIDError.ioKitError(code: -1).exitCode == 1)
            #expect(InspectHIDError.reportDescriptorNotAvailable.exitCode == 1)
            #expect(InspectHIDError.descriptorParseFailed(reason: "test").exitCode == 1)
        }

        @Test("InspectHIDError conforms to Equatable")
        func inspectHIDErrorIsEquatable() {
            let error1 = InspectHIDError.deviceNotFound(specifier: "0")
            let error2 = InspectHIDError.deviceNotFound(specifier: "0")
            let error3 = InspectHIDError.deviceNotFound(specifier: "1")

            #expect(error1 == error2, "Same errors should be equal")
            #expect(error1 != error3, "Different specifiers should not be equal")
        }

        @Test("InspectHIDError conforms to Sendable")
        func inspectHIDErrorIsSendable() {
            let error: any Sendable = InspectHIDError.deviceNotFound(specifier: "0")
            #expect(error is InspectHIDError)
        }

        @Test("InspectHIDError conforms to LocalizedError")
        func inspectHIDErrorIsLocalizedError() {
            let error: any LocalizedError = InspectHIDError.deviceNotFound(specifier: "test")
            #expect(error.errorDescription != nil, "Should have errorDescription")
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
            let errorCode: Int32 = -12345
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
            let errorCode: Int32 = -12345
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
            let error = IOKitErrorMapper.mapToInspectHIDError(code: IOKitErrorMapper.kIOReturnNotPermitted)
            if case .permissionDenied = error {
                #expect(error.exitCode == 2)
            } else {
                Issue.record("Should map to permissionDenied")
            }
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

        @Test("IOKitErrorMapper maps kIOReturnNotPermitted to permissionDenied")
        func mapperMapsNotPermittedToPermissionDenied() {
            let error = IOKitErrorMapper.mapToInspectHIDError(code: IOKitErrorMapper.kIOReturnNotPermitted)
            if case .permissionDenied = error {
                #expect(error.exitCode == 2)
            } else {
                Issue.record("Should map to permissionDenied")
            }
        }

        @Test("IOKitErrorMapper maps kIOReturnNotPrivileged to permissionDenied")
        func mapperMapsNotPrivilegedToPermissionDenied() {
            let error = IOKitErrorMapper.mapToInspectHIDError(code: IOKitErrorMapper.kIOReturnNotPrivileged)
            if case .permissionDenied = error {
                #expect(error.exitCode == 2)
            } else {
                Issue.record("Should map to permissionDenied")
            }
        }

        @Test("IOKitErrorMapper maps kIOReturnExclusiveAccess to permissionDenied")
        func mapperMapsExclusiveAccessToPermissionDenied() {
            let error = IOKitErrorMapper.mapToInspectHIDError(code: IOKitErrorMapper.kIOReturnExclusiveAccess)
            if case .permissionDenied = error {
                #expect(error.exitCode == 2)
            } else {
                Issue.record("Should map to permissionDenied")
            }
        }

        @Test("IOKitErrorMapper maps kIOReturnNoDevice to deviceDisconnected")
        func mapperMapsNoDeviceToDisconnected() {
            let error = IOKitErrorMapper.mapToInspectHIDError(code: IOKitErrorMapper.kIOReturnNoDevice)
            if case .deviceDisconnected = error {
                #expect(error.exitCode == 3)
            } else {
                Issue.record("Should map to deviceDisconnected")
            }
        }

        @Test("IOKitErrorMapper maps kIOReturnNotAttached to deviceDisconnected")
        func mapperMapsNotAttachedToDisconnected() {
            let error = IOKitErrorMapper.mapToInspectHIDError(code: IOKitErrorMapper.kIOReturnNotAttached)
            if case .deviceDisconnected = error {
                #expect(error.exitCode == 3)
            } else {
                Issue.record("Should map to deviceDisconnected")
            }
        }

        @Test("IOKitErrorMapper.isPermissionError returns true for permission codes")
        func isPermissionErrorReturnsTrueForPermissionCodes() {
            #expect(IOKitErrorMapper.isPermissionError(IOKitErrorMapper.kIOReturnNotPermitted))
            #expect(IOKitErrorMapper.isPermissionError(IOKitErrorMapper.kIOReturnNotPrivileged))
            #expect(IOKitErrorMapper.isPermissionError(IOKitErrorMapper.kIOReturnExclusiveAccess))
        }

        @Test("IOKitErrorMapper.isPermissionError returns false for other codes")
        func isPermissionErrorReturnsFalseForOtherCodes() {
            #expect(!IOKitErrorMapper.isPermissionError(IOKitErrorMapper.kIOReturnSuccess))
            #expect(!IOKitErrorMapper.isPermissionError(IOKitErrorMapper.kIOReturnBadArgument))
            #expect(!IOKitErrorMapper.isPermissionError(-12345))
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

    // MARK: - Monitoring Methods

    func open(_ device: any HIDDeviceHandle) throws { throw error }
    func open(_ device: any HIDDeviceHandle, exclusive: Bool) throws { throw error }
    func close(_ device: any HIDDeviceHandle) {}
    func registerInputReportCallbackWithId(_ device: any HIDDeviceHandle, callback: @escaping (Int, Data) -> Void) {}
    func registerRemovalCallback(_ device: any HIDDeviceHandle, callback: @escaping () -> Void) {}
    func runLoop() {}
    func stopRunLoop() {}
}
