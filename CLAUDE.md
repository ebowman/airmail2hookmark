# Airmail2Hookmark

A macOS utility that intercepts `airmail:` URIs and redirects them to [Hookmark](https://hookproductivity.com/) URIs, preserving existing email deep links after migrating away from Airmail.

## Background

Airmail has useful deep linking to emails via `airmail:` URIs. After switching to a different email client and using Hookmark for email linking, existing `airmail:` links would break. This app registers as the handler for the `airmail:` URL scheme and silently redirects to the equivalent Hookmark URL.

## URL Transformation

**Input format:**
```
airmail://message?mail={email}&messageid={id}
```

**Output format:**
```
hook://email/{id}
```

**Example:**
- Airmail: `airmail://message?mail=joe@user.com&messageid=AAMkADg1ZGM0ZGE3LWMxZDctNDBhOC04OWNhLTZhM2VlNjNhYzIxNQBGAAAAAADtYuK5T8IaS7TB7_AKKA9FBwBcJ6m9i2jPSbO7OUxjrFzMAAAAAAEMAABcJ6m9i2jPSbO7OUxjrFzMAAFRe7JEAAA%3D`
- Hookmark: `hook://email/AAMkADg1ZGM0ZGE3LWMxZDctNDBhOC04OWNhLTZhM2VlNjNhYzIxNQBGAAAAAADtYuK5T8IaS7TB7_AKKA9FBwBcJ6m9i2jPSbO7OUxjrFzMAAAAAAEMAABcJ6m9i2jPSbO7OUxjrFzMAAFRe7JEAAA%3D`

The `mail` parameter is discarded. The `messageid` parameter is extracted and used as-is (preserving URL encoding).

## Technical Requirements

- **Platform:** macOS (iOS version planned for future)
- **Language:** Swift
- **App type:** Background agent with menu bar icon (compatible with Bartender)
- **URL scheme:** Registers as handler for `airmail:` scheme

## User Interface

### Menu Bar
The app displays a menu bar icon with the following menu items:
- **About Airmail2Hookmark** - Shows app version and info
- **Settings...** - Opens settings dialog
- **Quit Airmail2Hookmark** - Exits the app

### Settings Dialog
- **Launch at Login** checkbox - Enables/disables auto-start when user logs in

## Behavior

- **Success:** Silently opens the transformed `hook://email/{id}` URL
- **Malformed URI:** Display an error dialog (e.g., missing `messageid` parameter)

## Distribution

Build from source for now. More sophisticated distribution options (Homebrew, DMG, etc.) may be added later.


