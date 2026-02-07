import Foundation
import Testing
@testable import InspectHIDCore

/// Tests for signal handling functionality
@Suite("Signal Handler Tests")
struct SignalHandlerTests {

    // MARK: - Test: SignalHandler protocol exists

    @Test("SignalHandlerProtocol defines required methods")
    func protocolDefinesRequiredMethods() {
        // Verify the protocol exists by creating a mock
        let handler = MockSignalHandler()
        _ = handler as any SignalHandlerProtocol
    }

    // MARK: - Test: Signal handler can register callback

    @Test("Can register SIGINT handler")
    func canRegisterSIGINTHandler() {
        let handler = MockSignalHandler()
        var callbackInvoked = false

        handler.onInterrupt {
            callbackInvoked = true
        }

        // Simulate signal
        handler.simulateSIGINT()

        #expect(callbackInvoked)
    }

    // MARK: - Test: Multiple signals invoke callback multiple times

    @Test("Multiple interrupts invoke callback each time")
    func multipleInterruptsInvokeCallback() {
        let handler = MockSignalHandler()
        var callCount = 0

        handler.onInterrupt {
            callCount += 1
        }

        handler.simulateSIGINT()
        handler.simulateSIGINT()
        handler.simulateSIGINT()

        #expect(callCount == 3)
    }

    // MARK: - Test: Signal handler replaces previous callback

    @Test("New callback replaces previous one")
    func newCallbackReplacesPrevious() {
        let handler = MockSignalHandler()
        var firstCallbackCalled = false
        var secondCallbackCalled = false

        handler.onInterrupt {
            firstCallbackCalled = true
        }

        handler.onInterrupt {
            secondCallbackCalled = true
        }

        handler.simulateSIGINT()

        #expect(!firstCallbackCalled)
        #expect(secondCallbackCalled)
    }

    // MARK: - Test: Signal handler can unregister

    @Test("Unregister removes callback")
    func unregisterRemovesCallback() {
        let handler = MockSignalHandler()
        var callbackInvoked = false

        handler.onInterrupt {
            callbackInvoked = true
        }

        handler.unregister()
        handler.simulateSIGINT()

        #expect(!callbackInvoked)
    }

    // MARK: - Test: SignalHandler singleton access

    @Test("SignalHandler provides shared instance")
    func signalHandlerProvidesSharedInstance() {
        let handler1 = SignalHandler.shared
        let handler2 = SignalHandler.shared

        #expect(handler1 === handler2)
    }

    // MARK: - Test: HIDDeviceService integration with signal handler

    @Test("HIDDeviceService stopMonitoring stops run loop via adapter")
    func deviceServiceStopMonitoringStopsRunLoop() throws {
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

        // stopMonitoring should close the device
        service.stopMonitoring()

        #expect(!adapter.openedDevices.contains { $0 === device })
    }

    // MARK: - Test: IOKitHIDAdapter runLoop and stopRunLoop

    @Test("IOKitHIDAdapter stopRunLoop can be called safely")
    func adapterStopRunLoopSafe() {
        let adapter = MockIOKitHIDAdapter(devices: [])

        // Should not crash when called without runLoop running
        adapter.stopRunLoop()
    }

    // MARK: - Test: HIDDeviceService runLoop/stopRunLoop integration

    @Test("HIDDeviceService has runLoop method")
    func deviceServiceHasRunLoopMethod() throws {
        let device = MockHIDDeviceHandle(
            vendorId: 0x1234,
            productId: 0x5678,
            productName: "Test Device",
            manufacturer: "Test",
            serialNumber: nil
        )
        let adapter = MockIOKitHIDAdapter(devices: [device])
        let service = HIDDeviceService(adapter: adapter)

        // runLoop method should exist (we don't actually call it in tests as it would block)
        _ = service as any HIDDeviceServiceProtocol
    }

    @Test("HIDDeviceService stopRunLoop forwards to adapter")
    func deviceServiceStopRunLoopForwardsToAdapter() throws {
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

        // stopRunLoop should be callable
        service.stopRunLoop()

        #expect(adapter.stopRunLoopCalled)
    }
}

// MARK: - Mock Signal Handler

/// Mock signal handler for testing
final class MockSignalHandler: SignalHandlerProtocol, @unchecked Sendable {
    private var callback: (() -> Void)?

    func onInterrupt(_ handler: @escaping () -> Void) {
        self.callback = handler
    }

    func unregister() {
        self.callback = nil
    }

    // Test helper
    func simulateSIGINT() {
        callback?()
    }
}
