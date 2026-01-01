# Airmail2Hookmark

A utility for macOS, iOS, and iPadOS that intercepts `airmail:` URIs and redirects them to [Hookmark](https://hookproductivity.com/) or Apple Mail URIs, preserving your existing email deep links after migrating away from Airmail.

## Background

[Airmail](https://airmailapp.com/) provides useful deep linking to emails via `airmail:` URIs. Once you start using these links extensively—in notes, documents, task managers, and other apps—you become deeply committed to Airmail as your email client. Unfortunately, Airmail has become buggy and isn't really evolving, but switching away is painful because all those `airmail:` links would break.

[Hookmark](https://hookproductivity.com/) offers its own email linking scheme (`hook://email/`) that's email-client agnostic—you can configure Hookmark to open emails in Airmail, Apple Mail, MailMate, Fastmail, or other clients. However, Hookmark won't intercept your existing `airmail:` URIs.

**That's where this utility comes in.** Install Airmail2Hookmark on your Mac, iPhone, and iPad, then uninstall Airmail. This app takes over responsibility for handling `airmail:` URIs and redirects them to either:
- **Hookmark** (`hook://email/{id}`) - which can open the email in your configured mail client
- **Apple Mail** (`message://%3C{id}%3E`) - which opens the email directly in Apple Mail

## Features

- **macOS**: Menu bar app that runs in the background
- **iOS/iPadOS**: Companion app for iPhone and iPad
- **Configurable output**: Choose between Hookmark or Apple Mail URL schemes
- **Silent operation**: URLs are redirected automatically without user interaction
- **Launch at login** (macOS): Optionally start automatically when you log in

## Requirements

### macOS
- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later (for building from source)
- [Hookmark](https://hookproductivity.com/) installed (if using Hookmark output mode)

### iOS/iPadOS
- iOS 16.0 or later / iPadOS 16.0 or later
- Xcode 15.0 or later (for building and installing)
- Apple ID (free account works, but has limitations - see below)

---

## Building and Installing

### Prerequisites

1. **Install Xcode** from the Mac App Store

2. **Set Xcode as the active developer directory** (required for command-line builds):
   ```bash
   sudo xcode-select -s /Applications/Xcode.app
   ```

3. **Clone the repository**:
   ```bash
   git clone https://github.com/ebowman/airmail2hookmark.git
   cd airmail2hookmark
   ```

4. **Open the project in Xcode**:
   ```bash
   open Airmail2Hookmark.xcodeproj
   ```

---

## macOS App

### Building

**Option 1: Using Xcode**
1. Open `Airmail2Hookmark.xcodeproj` in Xcode
2. Select the **Airmail2Hookmark** scheme (not the iOS one)
3. Select **My Mac** as the destination
4. Press **Cmd+B** to build, or **Cmd+R** to build and run

**Option 2: Using the build script**
```bash
./build-app.sh
```
This creates `Airmail2Hookmark.app` in the current directory.

### Installing

Copy the built app to your Applications folder:
```bash
cp -r Airmail2Hookmark.app /Applications/
```

Or drag `Airmail2Hookmark.app` from Finder to your Applications folder.

### Running

Double-click the app, or:
```bash
open /Applications/Airmail2Hookmark.app
```

The app appears as an icon in your menu bar. It runs silently in the background, intercepting `airmail:` URLs.

### Menu Bar Options

Click the menu bar icon to access:
- **About Airmail2Hookmark** - Shows app version
- **Settings...** - Configure output scheme and launch at login
- **Quit Airmail2Hookmark** - Exit the app

---

## iOS/iPadOS App

Installing apps on iPhone or iPad from source requires a few extra steps compared to macOS.

### Step 1: Set Up Code Signing

Before you can install the app on your device, you need to configure code signing in Xcode.

1. **Open the project** in Xcode:
   ```bash
   open Airmail2Hookmark.xcodeproj
   ```

2. **Select the project** in the navigator (the blue icon at the top of the file list)

3. **Select the Airmail2HookmarkiOS target** in the targets list

4. **Go to the "Signing & Capabilities" tab**

5. **Check "Automatically manage signing"**

6. **Select your Team**:
   - If you don't see a team, click **"Add Account..."**
   - Sign in with your Apple ID
   - Select your Personal Team (shows as "Your Name (Personal Team)")

> **Note**: A free Apple ID works for development, but apps expire after 7 days and must be reinstalled. A paid Apple Developer account ($99/year) removes this limitation.

### Step 2: Connect Your Device

1. **Connect your iPhone or iPad** to your Mac with a USB cable

2. **Trust the computer** on your device if prompted

3. **In Xcode**, select your device from the destination dropdown (top of the window, next to the scheme selector). It will appear as "Your Device Name" under "iOS Devices"

> **First time only**: If this is your first time using your device for development, you may need to enable Developer Mode on your device:
> - Go to **Settings > Privacy & Security > Developer Mode**
> - Enable Developer Mode and restart your device

### Step 3: Build and Install

1. **Select the Airmail2HookmarkiOS scheme** from the scheme dropdown

2. **Select your connected device** as the destination

3. **Press Cmd+R** (or click the Play button) to build and run

4. **First time only**: You may see an error about an untrusted developer:
   - On your device, go to **Settings > General > VPN & Device Management**
   - Tap on your Apple ID under "Developer App"
   - Tap **"Trust [your Apple ID]"**
   - Confirm by tapping **Trust**

5. **Run again** (Cmd+R) - the app should now launch on your device

### Step 4: Using the iOS App

Once installed, the app works in two ways:

1. **Opening the app directly**: Shows the Settings screen where you can choose between Hookmark and Apple Mail output schemes

2. **Tapping an airmail: link**: The app intercepts the link, transforms it, and opens the target app (Hookmark or Mail) - you won't see the Airmail2Hookmark interface at all

### Installing on Multiple Devices

Repeat Steps 2-3 for each device. Each device needs to:
- Be connected via USB
- Trust your computer
- Have Developer Mode enabled (iOS 16+)
- Trust your developer certificate

### Wireless Debugging (Optional)

After the initial USB setup, you can deploy wirelessly:

1. With your device connected via USB, go to **Window > Devices and Simulators** in Xcode
2. Select your device and check **"Connect via network"**
3. Once connected wirelessly (network globe icon appears), you can disconnect USB
4. Your device will appear in the destination list with a network icon

---

## URL Transformation

The app transforms Airmail URLs to either Hookmark or Apple Mail format:

### Input (Airmail)
```
airmail://message?mail=user%40example.com&messageid=ABC123XYZ
```

### Output (Hookmark mode)
```
hook://email/ABC123XYZ
```

### Output (Apple Mail mode)
```
message://%3CABC123XYZ%3E
```

The `mail` parameter is discarded. The `messageid` parameter is extracted and used in the output URL.

---

## Settings

### macOS
Access settings via the menu bar icon > **Settings...**
- **Output Scheme**: Choose between Hookmark (`hook://`) and Apple Mail (`message://`)
- **Launch at Login**: Start automatically when you log in

### iOS/iPadOS
Open the app to access settings:
- **Output Scheme**: Choose between Hookmark and Apple Mail

---

## How It Works

1. The app registers as the handler for the `airmail:` URL scheme
2. When an `airmail:` URL is opened, the OS routes it to this app
3. The app extracts the `messageid` parameter from the URL
4. It constructs either a `hook://email/{id}` or `message://%3C{id}%3E` URL
5. The transformed URL is opened, launching the appropriate app

---

## Troubleshooting

### macOS

**"Airmail2Hookmark" can't be opened because it is from an unidentified developer**
- Right-click the app and select "Open", then click "Open" in the dialog
- Or go to System Preferences > Security & Privacy and click "Open Anyway"

**Links still open in Airmail**
- Make sure Airmail is not installed, or
- Make sure Airmail2Hookmark was launched after Airmail was uninstalled
- Try running: `/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f /Applications/Airmail2Hookmark.app`

### iOS/iPadOS

**"Unable to install" error**
- Make sure Developer Mode is enabled on your device
- Make sure you've trusted your developer certificate in Settings

**App stops working after 7 days**
- Free Apple ID provisioning profiles expire after 7 days
- Reconnect your device and run from Xcode again to reinstall
- Consider a paid Apple Developer account to avoid this

**"Could not launch" - untrusted developer**
- Go to Settings > General > VPN & Device Management
- Trust your developer certificate

---

## Compatibility

This utility works with any email client that Hookmark supports, including:
- Apple Mail
- Outlook
- Spark
- And others

When using Apple Mail mode, emails are opened directly in Apple Mail without requiring Hookmark.

---

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Acknowledgments

- [Hookmark](https://hookproductivity.com/) for their excellent linking utility
- [Airmail](https://airmailapp.com/) for pioneering deep email links
