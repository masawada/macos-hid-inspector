import Foundation

/// Protocol for signal handling - allows dependency injection and testing
public protocol SignalHandlerProtocol: AnyObject, Sendable {
    /// Register a callback to be invoked when SIGINT (Ctrl+C) is received
    func onInterrupt(_ handler: @escaping () -> Void)

    /// Unregister the current interrupt handler
    func unregister()
}

/// Signal handler for catching SIGINT and other termination signals
/// Uses POSIX signal handling to catch Ctrl+C
public final class SignalHandler: SignalHandlerProtocol, @unchecked Sendable {
    /// Shared singleton instance
    public static let shared = SignalHandler()

    /// The callback to invoke when a signal is received
    private var interruptHandler: (() -> Void)?

    /// Private initializer for singleton pattern
    private init() {}

    /// Register a callback to be invoked when SIGINT (Ctrl+C) is received
    /// - Parameter handler: Callback to invoke on interrupt
    public func onInterrupt(_ handler: @escaping () -> Void) {
        interruptHandler = handler
        setupSignalHandler()
    }

    /// Unregister the current interrupt handler
    public func unregister() {
        interruptHandler = nil
        signal(SIGINT, SIG_DFL)
    }

    /// Set up the POSIX signal handler for SIGINT
    private func setupSignalHandler() {
        // Store self reference for the C callback
        SignalHandler.currentHandler = self

        signal(SIGINT) { _ in
            SignalHandler.currentHandler?.interruptHandler?()
        }
    }

    /// Static reference needed for C callback compatibility
    /// nonisolated(unsafe) is used because signal handlers require static context
    /// and we ensure thread-safety through the singleton pattern
    nonisolated(unsafe) private static var currentHandler: SignalHandler?
}
