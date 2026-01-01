# Privacy Policy for Airmail2Hookmark

**Last Updated: January 1, 2026**

## Overview

Airmail2Hookmark is a utility application for macOS, iOS, and iPadOS that redirects `airmail:` URLs to Hookmark or Apple Mail URLs. This privacy policy explains how the app handles your data.

## Data Collection

**Airmail2Hookmark does not collect, store, transmit, or share any personal data.**

Specifically, the app:

- Does **not** collect any personal information
- Does **not** collect usage analytics or statistics
- Does **not** use any third-party analytics services
- Does **not** contain any advertising
- Does **not** connect to any servers or internet services
- Does **not** access any data beyond the URLs it is asked to open

## Data Processing

When you click an `airmail:` URL, the app:

1. Receives the URL from the operating system
2. Extracts the email message ID from the URL
3. Constructs a new URL (either `hook://` or `message://` format)
4. Asks the operating system to open the new URL
5. Immediately discards all data—nothing is stored

## Local Storage

The app stores only one piece of information locally on your device:

- **Your output scheme preference** (Hookmark or Apple Mail)

This preference is stored using the operating system's standard preferences system (UserDefaults on Apple platforms) and never leaves your device.

## Third-Party Services

Airmail2Hookmark does not integrate with any third-party services. When the app opens a Hookmark or Apple Mail URL, it simply hands off to those applications—no data is shared with any external parties.

## Children's Privacy

The app does not collect any data from anyone, including children under 13.

## Changes to This Policy

If this privacy policy changes, the updated policy will be posted in the app's repository and the "Last Updated" date will be revised.

## Contact

If you have questions about this privacy policy, please open an issue on the project's GitHub repository:

https://github.com/ebowman/airmail2hookmark

## Summary

**Airmail2Hookmark collects no data. Your privacy is fully preserved.**
