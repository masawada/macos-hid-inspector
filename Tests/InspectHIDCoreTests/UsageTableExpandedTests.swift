import Testing
@testable import InspectHIDCore

/// Expanded tests for UsageTableLookup covering all usage pages from HID Usage Tables 1.7
@Suite("UsageTable Expanded Tests")
struct UsageTableExpandedTests {

    // MARK: - Dynamic Generation Tests

    @Test("Ordinal page returns Undefined for usage 0")
    func ordinalUndefined() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x0A, usage: 0x00) == "Undefined")
    }

    @Test("Ordinal page returns Instance N for non-zero usage")
    func ordinalInstance() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x0A, usage: 0x01) == "Instance 1")
        #expect(lookup.lookupUsageName(page: 0x0A, usage: 0x03) == "Instance 3")
        #expect(lookup.lookupUsageName(page: 0x0A, usage: 0xFF) == "Instance 255")
    }

    @Test("Monitor Enumerated page returns Undefined for usage 0")
    func monitorEnumeratedUndefined() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x81, usage: 0x00) == "Undefined")
    }

    @Test("Monitor Enumerated page returns Enum N for non-zero usage")
    func monitorEnumeratedEnum() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x81, usage: 0x01) == "Enum 1")
        #expect(lookup.lookupUsageName(page: 0x81, usage: 0x10) == "Enum 16")
        #expect(lookup.lookupUsageName(page: 0x81, usage: 0xFF) == "Enum 255")
    }

    // MARK: - SoC Page Name Test

    @Test("lookupPageName returns SoC for page 0x11")
    func socPageName() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupPageName(page: 0x11) == "SoC")
    }

    // MARK: - Spot Checks for All New Pages

    @Test("Simulation Controls (0x02) spot check")
    func simulationControlsSpotCheck() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x02, usage: 0x01) == "Flight Simulation Device")
        #expect(lookup.lookupUsageName(page: 0x02, usage: 0xB0) == "Aileron")
    }

    @Test("VR Controls (0x03) spot check")
    func vrControlsSpotCheck() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x03, usage: 0x01) == "Belt")
        #expect(lookup.lookupUsageName(page: 0x03, usage: 0x04) == "Glove")
    }

    @Test("Sport Controls (0x04) spot check")
    func sportControlsSpotCheck() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x04, usage: 0x01) == "Baseball Bat")
        #expect(lookup.lookupUsageName(page: 0x04, usage: 0x38) == "Stick Type")
    }

    @Test("Game Controls (0x05) spot check")
    func gameControlsSpotCheck() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x05, usage: 0x01) == "3D Game Controller")
        #expect(lookup.lookupUsageName(page: 0x05, usage: 0x20) == "Point of View")
    }

    @Test("Generic Device Controls (0x06) spot check")
    func genericDeviceControlsSpotCheck() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x06, usage: 0x20) == "Battery Strength")
        #expect(lookup.lookupUsageName(page: 0x06, usage: 0x24) == "Security Code Character Entered")
    }

    @Test("Telephony Device (0x0B) spot check")
    func telephonyDeviceSpotCheck() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x0B, usage: 0x01) == "Phone")
        #expect(lookup.lookupUsageName(page: 0x0B, usage: 0x21) == "Flash")
    }

    @Test("Digitizers (0x0D) spot check")
    func digitizersSpotCheck() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x0D, usage: 0x01) == "Digitizer")
        #expect(lookup.lookupUsageName(page: 0x0D, usage: 0x42) == "Tip Switch")
    }

    @Test("Haptics (0x0E) spot check")
    func hapticsSpotCheck() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x0E, usage: 0x01) == "Simple Haptic Controller")
        #expect(lookup.lookupUsageName(page: 0x0E, usage: 0x10) == "Waveform List")
    }

    @Test("Physical Input Device (0x0F) spot check")
    func physicalInputDeviceSpotCheck() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x0F, usage: 0x01) == "Physical Input Device")
        #expect(lookup.lookupUsageName(page: 0x0F, usage: 0x58) == "Type Specific Block Offset")
    }

    @Test("SoC (0x11) spot check")
    func socSpotCheck() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x11, usage: 0x01) == "SocControl")
        #expect(lookup.lookupUsageName(page: 0x11, usage: 0x03) == "FirmwareFileId")
    }

    @Test("Eye and Head Trackers (0x12) spot check")
    func eyeAndHeadTrackersSpotCheck() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x12, usage: 0x01) == "Eye Tracker")
        #expect(lookup.lookupUsageName(page: 0x12, usage: 0x10) == "Tracking Data")
    }

    @Test("Auxiliary Display (0x14) spot check")
    func auxiliaryDisplaySpotCheck() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x14, usage: 0x01) == "Alphanumeric Display")
        #expect(lookup.lookupUsageName(page: 0x14, usage: 0x20) == "Display Attributes Report")
    }

    @Test("Sensors (0x20) spot check")
    func sensorsSpotCheck() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x20, usage: 0x01) == "Sensor")
        #expect(lookup.lookupUsageName(page: 0x20, usage: 0x11) == "Biometric: Human Presence")
    }

    @Test("Medical Instrument (0x40) spot check")
    func medicalInstrumentSpotCheck() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x40, usage: 0x01) == "Medical Ultrasound")
        #expect(lookup.lookupUsageName(page: 0x40, usage: 0x21) == "Freeze/Thaw")
    }

    @Test("Braille Display (0x41) spot check")
    func brailleDisplaySpotCheck() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x41, usage: 0x01) == "Braille Display")
        #expect(lookup.lookupUsageName(page: 0x41, usage: 0x02) == "Braille Row")
    }

    @Test("Lighting And Illumination (0x59) spot check")
    func lightingAndIlluminationSpotCheck() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x59, usage: 0x01) == "LampArray")
        #expect(lookup.lookupUsageName(page: 0x59, usage: 0x22) == "LampAttributesResponseReport")
    }

    @Test("Monitor (0x80) spot check")
    func monitorSpotCheck() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x80, usage: 0x01) == "Monitor Control")
        #expect(lookup.lookupUsageName(page: 0x80, usage: 0x02) == "EDID Information")
    }

    @Test("VESA Virtual Controls (0x82) spot check")
    func vesaVirtualControlsSpotCheck() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x82, usage: 0x10) == "Brightness")
        #expect(lookup.lookupUsageName(page: 0x82, usage: 0x12) == "Contrast")
    }

    @Test("Power (0x84) spot check")
    func powerSpotCheck() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x84, usage: 0x01) == "iName")
        #expect(lookup.lookupUsageName(page: 0x84, usage: 0x1A) == "Input")
    }

    @Test("Battery System (0x85) spot check")
    func batterySystemSpotCheck() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x85, usage: 0x01) == "Smart Battery Battery Mode")
        #expect(lookup.lookupUsageName(page: 0x85, usage: 0x66) == "Remaining Capacity")
    }

    @Test("Barcode Scanner (0x8C) spot check")
    func barcodeScannerSpotCheck() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x8C, usage: 0x01) == "Barcode Badge Reader")
        #expect(lookup.lookupUsageName(page: 0x8C, usage: 0x10) == "Attribute Report")
    }

    @Test("Scales (0x8D) spot check")
    func scalesSpotCheck() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x8D, usage: 0x01) == "Scales")
        #expect(lookup.lookupUsageName(page: 0x8D, usage: 0x52) == "Weight Unit Gram")
    }

    @Test("Magnetic Stripe Reader (0x8E) spot check")
    func magneticStripeReaderSpotCheck() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x8E, usage: 0x01) == "MSR Device Read-Only")
        #expect(lookup.lookupUsageName(page: 0x8E, usage: 0x21) == "Track 1 Data")
    }

    @Test("Camera Control (0x90) spot check")
    func cameraControlSpotCheck() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x90, usage: 0x20) == "Camera Auto-focus")
        #expect(lookup.lookupUsageName(page: 0x90, usage: 0x21) == "Camera Shutter")
    }

    @Test("Arcade (0x91) spot check")
    func arcadeSpotCheck() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0x91, usage: 0x01) == "General Purpose IO Card")
        #expect(lookup.lookupUsageName(page: 0x91, usage: 0x41) == "Watchdog Timeout")
    }

    @Test("FIDO Alliance (0xF1D0) spot check")
    func fidoAllianceSpotCheck() {
        let lookup = UsageTableLookup()
        #expect(lookup.lookupUsageName(page: 0xF1D0, usage: 0x01) == "U2F Authenticator Device")
        #expect(lookup.lookupUsageName(page: 0xF1D0, usage: 0x20) == "Input Report Data")
    }

    // MARK: - Coverage Verification

    @Test("All non-dynamic pages have entries in allUsageTables")
    func allPagesHaveEntries() {
        let expectedPages: [UInt16] = [
            0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
            0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x11, 0x12, 0x14,
            0x20, 0x40, 0x41, 0x59, 0x80, 0x82, 0x84, 0x85,
            0x8C, 0x8D, 0x8E, 0x90, 0x91, 0xF1D0,
        ]
        for page in expectedPages {
            let table = UsageTableLookup.allUsageTables[page]
            #expect(table != nil, "Missing usage table for page 0x\(String(format: "%04X", page))")
            #expect(table!.count > 0, "Empty usage table for page 0x\(String(format: "%04X", page))")
        }
    }

    @Test("Dynamic pages are not in allUsageTables")
    func dynamicPagesNotInTables() {
        // Button (0x09), Ordinal (0x0A), Monitor Enumerated (0x81) are handled dynamically
        #expect(UsageTableLookup.allUsageTables[0x09] == nil)
        #expect(UsageTableLookup.allUsageTables[0x0A] == nil)
        #expect(UsageTableLookup.allUsageTables[0x81] == nil)
    }

    @Test("allUsageTables count matches expected number of pages")
    func allUsageTablesCount() {
        #expect(UsageTableLookup.allUsageTables.count == 30)
    }
}
