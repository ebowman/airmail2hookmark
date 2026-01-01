# SPARC Plan: URI Scheme Preference Feature

## S - Specification

### Goal
Add a user preference to choose between `hook:` and `message:` URI schemes when transforming Airmail URLs.

### Requirements
1. Add radio button preference in Settings dialog with two options:
   - **Hookmark** (`hook://email/{id}`) - DEFAULT
   - **Apple Mail** (`message://%3C{id}%3E`)
2. Persist the setting using `UserDefaults`
3. Setting takes effect immediately (no restart required)

### URL Transformation Formats
| Scheme | Format | Example |
|--------|--------|---------|
| Hookmark | `hook://email/{messageid}` | `hook://email/AAMkADg1...` |
| Apple Mail | `message://%3C{messageid}%3E` | `message://%3CAAMkADg1...%3E` |

Note: The `message:` scheme wraps the message ID in angle brackets (`<` `>`), URL-encoded as `%3C` and `%3E`.

---

## P - Pseudocode

### 1. Settings Storage (new PreferencesManager)
```
enum URIScheme: String
    case hookmark = "hook"
    case applemail = "message"

class PreferencesManager
    static shared instance

    property selectedScheme: URIScheme
        get: read from UserDefaults, default to .hookmark
        set: write to UserDefaults
```

### 2. URLTransformer Modification
```
function transform(airmailURL, scheme) -> Result<URL>
    validate airmail scheme
    extract messageid

    if scheme == .hookmark:
        return "hook://email/{messageid}"
    else if scheme == .applemail:
        return "message://%3C{messageid}%3E"
```

### 3. Settings UI Update
```
SettingsWindowController:
    add radio button group:
        - "Hookmark (hook://)"
        - "Apple Mail (message://)"

    on selection change:
        PreferencesManager.shared.selectedScheme = selected
```

### 4. AppDelegate Update
```
function handleAirmailURL(url):
    scheme = PreferencesManager.shared.selectedScheme
    result = URLTransformer.transform(url, scheme: scheme)
    // ... rest unchanged
```

---

## A - Architecture

### File Changes

```
Airmail2Hookmark/
├── Sources/
│   ├── Services/
│   │   ├── URLTransformer.swift      # MODIFY - add scheme parameter
│   │   ├── PreferencesManager.swift  # NEW - UserDefaults wrapper
│   │   └── LoginItemManager.swift    # unchanged
│   ├── UI/
│   │   └── SettingsWindowController.swift  # MODIFY - add radio buttons
│   └── App/
│       └── AppDelegate.swift         # MODIFY - pass scheme to transformer
└── Tests/
    └── URLTransformerTests.swift     # MODIFY - test both schemes
```

### Data Flow
```
┌─────────────────┐     ┌─────────────────────┐     ┌─────────────────┐
│  Settings UI    │────▶│ PreferencesManager  │◀────│   AppDelegate   │
│  (radio btns)   │     │   (UserDefaults)    │     │ (URL handling)  │
└─────────────────┘     └─────────────────────┘     └────────┬────────┘
                                                              │
                                                              ▼
                                                    ┌─────────────────┐
                                                    │  URLTransformer │
                                                    │  (with scheme)  │
                                                    └─────────────────┘
```

### UserDefaults Key
- Key: `"selectedURIScheme"`
- Values: `"hook"` (default) or `"message"`

---

## R - Refinement

### Implementation Order
1. **PreferencesManager.swift** - Create new file with UserDefaults logic
2. **URLTransformer.swift** - Add scheme enum and parameter
3. **URLTransformerTests.swift** - Update tests for both schemes
4. **SettingsWindowController.swift** - Add radio button UI
5. **AppDelegate.swift** - Wire up scheme selection

### UI Layout (Settings Window)
```
┌─────────────────────────────────────┐
│ Settings                        [X] │
├─────────────────────────────────────┤
│                                     │
│ ☑ Launch at Login                   │
│   Automatically start when you      │
│   log in.                           │
│                                     │
│ ─────────────────────────────────── │
│                                     │
│ Output URL Scheme:                  │
│ ○ Hookmark (hook://email/...)       │
│ ● Apple Mail (message://...)        │
│                                     │
└─────────────────────────────────────┘
```

Window height: Increase from 100 to ~180 pixels

### Edge Cases
- First launch: Default to Hookmark (no migration needed)
- Invalid stored value: Fall back to Hookmark
- Scheme change mid-session: Takes effect on next URL handled

---

## C - Completion Checklist

### Files to Create
- [ ] `Airmail2Hookmark/Sources/Services/PreferencesManager.swift`

### Files to Modify
- [ ] `Airmail2Hookmark/Sources/Services/URLTransformer.swift`
  - Add `URIScheme` enum
  - Add `scheme` parameter to `transform()` method
  - Implement `message://` URL construction

- [ ] `Airmail2Hookmark/Sources/UI/SettingsWindowController.swift`
  - Increase window height
  - Add separator line
  - Add "Output URL Scheme:" label
  - Add radio button group
  - Wire up preference changes

- [ ] `Airmail2Hookmark/Sources/App/AppDelegate.swift`
  - Read scheme from PreferencesManager
  - Pass scheme to URLTransformer

- [ ] `Airmail2Hookmark/Tests/URLTransformerTests.swift`
  - Add tests for `message://` scheme
  - Update existing tests to specify scheme

### Testing Plan
1. Build and run app
2. Verify default is Hookmark
3. Change to Apple Mail, verify setting persists after restart
4. Test URL transformation for both schemes
5. Test with malformed URLs (error handling unchanged)

---

## Summary

This is a small, focused feature addition with minimal risk:
- **1 new file** (PreferencesManager.swift ~30 lines)
- **4 modified files** (small changes each)
- **No breaking changes** to existing behavior
- **Backward compatible** (default matches current behavior)

Estimated scope: ~100-150 lines of code changes total.
