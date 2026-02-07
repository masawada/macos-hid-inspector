# macos-hid-inspector

A command-line tool for inspecting and monitoring Human Interface Devices (HID) on macOS.

## Features

- List all connected HID devices with vendor/product IDs
- Display USB device descriptor information
- Parse and display HID report descriptors with human-readable usage names
- Monitor real-time HID reports from devices
- JSON output support for all commands

## Requirements

- macOS 14.0+
- Swift 6.0+
- Input Monitoring permission (System Settings > Privacy & Security > Input Monitoring)

## Installation

### Build from source

```bash
git clone https://github.com/masawada/macos-hid-inspector.git
cd macos-hid-inspector
swift build -c release
```

The binary will be at `.build/release/inspect-hid`.

## Permissions

macOS requires Input Monitoring permission to access HID devices. If you see a permission error:

1. Open **System Settings** > **Privacy & Security** > **Input Monitoring**
2. Add your terminal application (Terminal.app, iTerm2, etc.)
3. Restart the terminal

> [!CAUTION]
> **Input Monitoring permission allows applications to read all keyboard and mouse input, which means any program with this permission could potentially act as a keylogger.**
>
> - **Revoke permission when not in use** - Disable Input Monitoring for your terminal when you're done using this tool
> - **Use a dedicated terminal** - Consider using a separate terminal app exclusively for HID inspection
> - **Review permissions regularly** - Periodically check which apps have Input Monitoring access in System Settings

## Usage

### List devices

```
$ inspect-hid list
#      VID     PID     Product Name
------------------------------------------------------------
0      0x05AC  0x0262  Magic Mouse
1      0x05AC  0x030D  Magic Keyboard with Touch ID
```

### Show device descriptor

```
$ inspect-hid descriptor 0
Device Descriptor:
----------------------------------------
  bDeviceClass     : 0x00 (0)
  bDeviceSubClass  : 0x00 (0)
  bDeviceProtocol  : 0x00 (0)
  idVendor         : 0x05AC
  idProduct        : 0x0262
  bcdDevice        : 6.07
  iManufacturer    : Apple
  iProduct         : Magic Mouse
  iSerialNumber    : AA00BB11CCDD
```

Devices can be specified by index number or `VID:PID`:

```
$ inspect-hid descriptor 05AC:0262
$ inspect-hid descriptor 0x05AC:0x0262
```

### Show HID usage information

```
$ inspect-hid usage 0
0x05 0x01 // Usage Page (Generic Desktop)
0x09 0x02 // Usage (Mouse)
0xA1 0x01 //   Collection (Application)
0x05 0x09 //     Usage Page (Button)
0x19 0x01 //     Usage Minimum (Button 1)
0x29 0x03 //     Usage Maximum (Button 3)
0x15 0x00 //     Logical Minimum (0)
0x25 0x01 //     Logical Maximum (1)
0x95 0x03 //     Report Count (3)
0x75 0x01 //     Report Size (1)
0x81 0x02 //     Input (Data, Variable, Absolute)
0xC0      //   End Collection
```

### Monitor device reports

```
$ inspect-hid monitor 0
[14:32:01.123] 01 00 FE 00
[14:32:01.131] 01 00 FF 00
[14:32:01.139] 00 00 00 00
```

By default, the device is opened in shared mode. Use `--exclusive` to seize the device:

```
$ inspect-hid monitor 0 --exclusive
```

Press Ctrl+C to stop monitoring.

### JSON output

All commands support `--json` for machine-readable output:

```
$ inspect-hid list --json
$ inspect-hid descriptor 0 --json
$ inspect-hid usage 0 --json
$ inspect-hid monitor 0 --json
```

## License

MIT
