import Testing
@testable import InspectHIDCore

struct PackageSetupTests {

    @Test("InspectHIDCore library is importable")
    func coreLibraryIsAccessible() {
        // If this test passes, the package structure is correctly configured
        #expect(Bool(true))
    }

    @Test("Version constant exists")
    func versionConstantExists() {
        #expect(!InspectHIDCore.version.isEmpty)
    }
}
