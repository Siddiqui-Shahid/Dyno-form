# Edge Cases — DynoForm

Matrix of defensive behaviors and how to verify each one.

## Parsing and resilience

| Edge case | Expected behavior | How to trigger |
|-----------|-------------------|----------------|
| Unknown field type (`DATE_PICKER`) | Field ignored; app does not crash | Load `campaign_form.json` — `launch_date` (order 99) is not rendered |
| Malformed field object | Field skipped; other fields load | DEBUG → **Form JSON** → **Edge Cases Form** — `broken_field` has no `type` |
| Missing `fields` key | Empty form, title still shows | Unit test `testMissingFieldsDefaultsToEmpty` with `missing_fields_form.json` |
| `fields: null` | Treated as empty array | Decode `FormResponseDTO` with null fields (same as missing) |
| Dropdown with empty `options` | Field not rendered | Edge Cases Form → "No Options" dropdown absent |
| Invalid `default_values` | Invalid IDs filtered out | Edge Cases Form → Networks defaults to Meta only (not `net_invalid`) |
| Missing `theme` | Default colors applied | Remove theme from JSON — app uses `#FFFFFF`, `#111827`, etc. |
| Missing optional fields | Placeholder, supporting text, max_length ignored if absent | Compare TEXT fields with/without `placeholder` in JSON |

## UI and validation

| Edge case | Expected behavior | How to trigger |
|-----------|-------------------|----------------|
| Required field empty on Submit | Red error under field | Tap Submit with empty Campaign Name |
| `max_length` exceeded while typing | Input clamped; counter turns red at limit | Type 31+ chars in Campaign Name (max 30) |
| NUMBER subtype with text | Validation error on Submit | Enter "abc" in Daily Budget → Submit |
| Regex on URI field | Custom error if pattern fails | Landing Page URL: enter `ftp://bad` → Submit |
| Checkbox required | Error until checked | Submit without accepting Terms |
| Multi-select dropdown | State is `[String]` of IDs | Select Google + Meta → Submit → JSON shows `["net_google","net_meta"]` |

## Submission output

| Edge case | Expected behavior | How to trigger |
|-----------|-------------------|----------------|
| Valid form | JSON printed to Xcode console + alert | Fill all required fields → Submit |
| Single-select dropdown | Payload value is `String` | Use a form with `allow_multiple: false` |
| Multi-select dropdown | Payload value is `[String]` | Ad Networks in campaign form |
| Toggle / Checkbox | Payload value is `Bool` | Enable Tracking toggle in campaign form |

## Theming

| Edge case | Expected behavior | How to trigger |
|-----------|-------------------|----------------|
| `text_color` | Labels and title use theme color | Compare campaign vs edge case form (different `#text_color`) |
| `border_color` | Text fields and dropdowns use border color | Edge Cases Form uses `#9CA3AF` borders |
| `error_color` | Validation errors use theme error color | Submit invalid form |
| Invalid hex in theme | Falls back to system defaults | (Optional) corrupt a hex string in JSON |

## Focus management

| Edge case | Expected behavior | How to trigger |
|-----------|-------------------|----------------|
| Next button | Moves focus to next text field | Focus Campaign Name → keyboard toolbar → **Next** |
| Done button | Dismisses keyboard | Tap **Done** on keyboard toolbar |
| Multiline field | Excluded from Next chain | Campaign Notes uses TextEditor without Next navigation |

## Checkbox links

| Edge case | Expected behavior | How to trigger |
|-----------|-------------------|----------------|
| Metadata substring match | Substring is tappable link | Tap "Terms of Service" on accept checkbox |
| `clickable_text_color` | Link uses custom color | Link appears blue (`#2563EB`) |
| Open URL | Safari opens metadata URL | Tap link → `https://example.com/terms` |

## Manual QA checklist

- [ ] App launches to single form screen (no gallery tab in Release)
- [ ] All campaign form fields render except DATE_PICKER
- [ ] Edge case form loads via DEBUG menu
- [ ] Submit prints JSON to console
- [ ] Submit shows alert with JSON
- [ ] All 5 unit tests pass

## Switching test payloads (DEBUG only)

1. Run app in Debug configuration
2. Tap **Form JSON** (top-right navigation bar)
3. Choose **Campaign Form** or **Edge Cases Form**
