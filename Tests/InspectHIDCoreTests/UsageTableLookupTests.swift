import Testing
@testable import InspectHIDCore

/// Tests for UsageTableLookup
@Suite("UsageTableLookup Tests")
struct UsageTableLookupTests {

    // MARK: - Usage Page Name Tests

    @Test("lookupPageName returns Generic Desktop Page for page 0x01")
    func lookupPageNameGenericDesktop() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupPageName(page: 0x01)
        #expect(name == "Generic Desktop Page")
    }

    @Test("lookupPageName returns Simulation Controls for page 0x02")
    func lookupPageNameSimulationControls() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupPageName(page: 0x02)
        #expect(name == "Simulation Controls")
    }

    @Test("lookupPageName returns VR Controls for page 0x03")
    func lookupPageNameVRControls() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupPageName(page: 0x03)
        #expect(name == "VR Controls")
    }

    @Test("lookupPageName returns Sport Controls for page 0x04")
    func lookupPageNameSportControls() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupPageName(page: 0x04)
        #expect(name == "Sport Controls")
    }

    @Test("lookupPageName returns Game Controls for page 0x05")
    func lookupPageNameGameControls() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupPageName(page: 0x05)
        #expect(name == "Game Controls")
    }

    @Test("lookupPageName returns Generic Device Controls for page 0x06")
    func lookupPageNameGenericDeviceControls() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupPageName(page: 0x06)
        #expect(name == "Generic Device Controls")
    }

    @Test("lookupPageName returns Keyboard/Keypad for page 0x07")
    func lookupPageNameKeyboard() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupPageName(page: 0x07)
        #expect(name == "Keyboard/Keypad")
    }

    @Test("lookupPageName returns LED for page 0x08")
    func lookupPageNameLED() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupPageName(page: 0x08)
        #expect(name == "LED")
    }

    @Test("lookupPageName returns Button for page 0x09")
    func lookupPageNameButton() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupPageName(page: 0x09)
        #expect(name == "Button")
    }

    @Test("lookupPageName returns Ordinal for page 0x0A")
    func lookupPageNameOrdinal() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupPageName(page: 0x0A)
        #expect(name == "Ordinal")
    }

    @Test("lookupPageName returns Consumer for page 0x0C")
    func lookupPageNameConsumer() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupPageName(page: 0x0C)
        #expect(name == "Consumer")
    }

    @Test("lookupPageName returns Digitizers for page 0x0D")
    func lookupPageNameDigitizers() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupPageName(page: 0x0D)
        #expect(name == "Digitizers")
    }

    @Test("lookupPageName returns Haptics for page 0x0E")
    func lookupPageNameHaptics() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupPageName(page: 0x0E)
        #expect(name == "Haptics")
    }

    @Test("lookupPageName returns Physical Input Device for page 0x0F")
    func lookupPageNamePhysicalInputDevice() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupPageName(page: 0x0F)
        #expect(name == "Physical Input Device")
    }

    @Test("lookupPageName returns hex string for unknown page")
    func lookupPageNameUnknown() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupPageName(page: 0xFF00)
        #expect(name == "0xFF00")
    }

    @Test("lookupPageName returns hex string for undefined page")
    func lookupPageNameUndefined() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupPageName(page: 0x00)
        #expect(name == "Undefined")
    }

    // MARK: - Usage Name Tests (Generic Desktop Page 0x01)

    @Test("lookupUsageName returns Pointer for Generic Desktop 0x01")
    func lookupUsageNamePointer() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupUsageName(page: 0x01, usage: 0x01)
        #expect(name == "Pointer")
    }

    @Test("lookupUsageName returns Mouse for Generic Desktop 0x02")
    func lookupUsageNameMouse() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupUsageName(page: 0x01, usage: 0x02)
        #expect(name == "Mouse")
    }

    @Test("lookupUsageName returns Joystick for Generic Desktop 0x04")
    func lookupUsageNameJoystick() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupUsageName(page: 0x01, usage: 0x04)
        #expect(name == "Joystick")
    }

    @Test("lookupUsageName returns Gamepad for Generic Desktop 0x05")
    func lookupUsageNameGamePad() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupUsageName(page: 0x01, usage: 0x05)
        #expect(name == "Gamepad")
    }

    @Test("lookupUsageName returns Keyboard for Generic Desktop 0x06")
    func lookupUsageNameKeyboard() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupUsageName(page: 0x01, usage: 0x06)
        #expect(name == "Keyboard")
    }

    @Test("lookupUsageName returns Keypad for Generic Desktop 0x07")
    func lookupUsageNameKeypad() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupUsageName(page: 0x01, usage: 0x07)
        #expect(name == "Keypad")
    }

    @Test("lookupUsageName returns X for Generic Desktop 0x30")
    func lookupUsageNameX() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupUsageName(page: 0x01, usage: 0x30)
        #expect(name == "X")
    }

    @Test("lookupUsageName returns Y for Generic Desktop 0x31")
    func lookupUsageNameY() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupUsageName(page: 0x01, usage: 0x31)
        #expect(name == "Y")
    }

    @Test("lookupUsageName returns Z for Generic Desktop 0x32")
    func lookupUsageNameZ() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupUsageName(page: 0x01, usage: 0x32)
        #expect(name == "Z")
    }

    @Test("lookupUsageName returns Rx for Generic Desktop 0x33")
    func lookupUsageNameRx() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupUsageName(page: 0x01, usage: 0x33)
        #expect(name == "Rx")
    }

    @Test("lookupUsageName returns Ry for Generic Desktop 0x34")
    func lookupUsageNameRy() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupUsageName(page: 0x01, usage: 0x34)
        #expect(name == "Ry")
    }

    @Test("lookupUsageName returns Rz for Generic Desktop 0x35")
    func lookupUsageNameRz() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupUsageName(page: 0x01, usage: 0x35)
        #expect(name == "Rz")
    }

    @Test("lookupUsageName returns Wheel for Generic Desktop 0x38")
    func lookupUsageNameWheel() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupUsageName(page: 0x01, usage: 0x38)
        #expect(name == "Wheel")
    }

    @Test("lookupUsageName returns Hat Switch for Generic Desktop 0x39")
    func lookupUsageNameHatSwitch() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupUsageName(page: 0x01, usage: 0x39)
        #expect(name == "Hat Switch")
    }

    // MARK: - Usage Name Tests (Consumer Page 0x0C)

    @Test("lookupUsageName returns Consumer Control for Consumer 0x01")
    func lookupUsageNameConsumerControl() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupUsageName(page: 0x0C, usage: 0x01)
        #expect(name == "Consumer Control")
    }

    @Test("lookupUsageName returns Volume for Consumer 0xE0")
    func lookupUsageNameVolume() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupUsageName(page: 0x0C, usage: 0xE0)
        #expect(name == "Volume")
    }

    @Test("lookupUsageName returns Mute for Consumer 0xE2")
    func lookupUsageNameMute() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupUsageName(page: 0x0C, usage: 0xE2)
        #expect(name == "Mute")
    }

    @Test("lookupUsageName returns Volume Increment for Consumer 0xE9")
    func lookupUsageNameVolumeIncrement() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupUsageName(page: 0x0C, usage: 0xE9)
        #expect(name == "Volume Increment")
    }

    @Test("lookupUsageName returns Volume Decrement for Consumer 0xEA")
    func lookupUsageNameVolumeDecrement() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupUsageName(page: 0x0C, usage: 0xEA)
        #expect(name == "Volume Decrement")
    }

    // MARK: - Button Page Tests (0x09)

    @Test("lookupUsageName returns Button N for Button page")
    func lookupUsageNameButton() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x09, usage: 0x01) == "Button 1")
        #expect(lookup.lookupUsageName(page: 0x09, usage: 0x02) == "Button 2")
        #expect(lookup.lookupUsageName(page: 0x09, usage: 0x10) == "Button 16")
    }

    @Test("lookupUsageName returns No Button Pressed for Button 0")
    func lookupUsageNameNoButton() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x09, usage: 0x00) == "No Button Pressed")
    }

    // MARK: - Unknown Usage Tests

    @Test("lookupUsageName returns hex string for unknown usage in known page")
    func lookupUsageNameUnknownInKnownPage() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupUsageName(page: 0x01, usage: 0xFFFF)
        #expect(name == "0xFFFF")
    }

    @Test("lookupUsageName returns hex string for unknown page and usage")
    func lookupUsageNameUnknownPageAndUsage() {
        let lookup = UsageTableLookup()
        let name = lookup.lookupUsageName(page: 0xFF00, usage: 0x1234)
        #expect(name == "0x1234")
    }

    // MARK: - Protocol Conformance Tests

    @Test("UsageTableLookup conforms to UsageTableLookupProtocol")
    func protocolConformance() {
        let lookup: any UsageTableLookupProtocol = UsageTableLookup()
        #expect(lookup.lookupPageName(page: 0x01) == "Generic Desktop Page")
    }
}
