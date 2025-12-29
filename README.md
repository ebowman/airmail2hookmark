# Airmail2Hookmark

A macOS menu bar utility that intercepts `airmail:` URIs and redirects them to [Hookmark](https://hookproductivity.com/) URIs, preserving your existing email deep links after migrating away from Airmail.

## Background

[Airmail](https://airmailapp.com/) provides useful deep linking to emails via `airmail:` URIs. If you've been using [Hookmark](https://hookproductivity.com/) to create links to emails in Airmail and later switch to a different email client, those links would break.

This utility registers as the handler for the `airmail:` URL scheme and silently redirects to the equivalent Hookmark URL, which can then open the email in your current mail client (assuming Hookmark is configured to work with it).

## Requirements

- macOS 13.0 (Ventura) or later
- [Hookmark](https://hookproductivity.com/) installed and configured for your email client

## Installation

### Build from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/airmail2hookmark.git
   cd airmail2hookmark
   ```

2. Build the app:
   ```bash
   ./build-app.sh
   ```

3. Copy to Applications (optional):
   ```bash
   cp -r Airmail2Hookmark.app /Applications/
   ```

4. Run the app:
   ```bash
   open Airmail2Hookmark.app
   ```

### Using Xcode

Open `Airmail2Hookmark.xcodeproj` in Xcode and build/run from there.

## Usage

Once running, Airmail2Hookmark sits in your menu bar. Any `airmail:` URLs will automatically be intercepted and redirected to Hookmark.

### Menu Bar Options

- **About Airmail2Hookmark** - Shows app version and info
- **Settings...** - Opens settings dialog
- **Quit Airmail2Hookmark** - Exits the app

### Settings

- **Launch at Login** - Enable to start the app automatically when you log in

## URL Transformation

The app transforms URLs as follows:

**Input (Airmail):**
```
airmail://message?mail=user%40example.com&messageid=ABC123
```

**Output (Hookmark):**
```
hook://email/ABC123
```

The `mail` parameter is discarded. The `messageid` parameter is extracted and passed to Hookmark.

## How It Works

1. The app registers as the handler for the `airmail:` URL scheme
2. When an `airmail:` URL is opened, macOS routes it to this app
3. The app extracts the `messageid` parameter from the URL
4. It constructs a `hook://email/{messageid}` URL and opens it
5. Hookmark handles the `hook:` URL and opens the email in your configured mail client

## Compatibility

This utility works with any email client that Hookmark supports, including:
- Apple Mail
- Outlook
- Spark
- And others

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Acknowledgments

- [Hookmark](https://hookproductivity.com/) for their excellent linking utility
- [Airmail](https://airmailapp.com/) for pioneering deep email links on macOS
