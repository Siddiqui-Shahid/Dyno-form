# Demo Video Script — DynoForm (30–60 seconds)

Use this script to record your submission demo. Aim for **45 seconds**; 30s is the minimum, 60s the maximum.

## Before recording

1. Open **DynoForm.xcodeproj** in Xcode
2. Show the **Debug console** (View → Debug Area → Activate Console, or `⇧⌘C`)
3. Run on **iPhone simulator** (iOS 16+)
4. Optional: use QuickTime **File → New Screen Recording** or macOS screenshot toolbar video

## Shot list

### Shot 1 — Launch (0:00 – 0:05)

**Action:** Run the app (`⌘R`).

**Say (optional):** "DynoForm loads a server-driven UI entirely from local JSON."

**Show:** "Campaign Setup" title, themed white background, form fields visible.

---

### Shot 2 — Dynamic fields + max length (0:05 – 0:15)

**Action:**
- Tap **Campaign Name**
- Type a name (e.g. "Summer Sale")
- Point at the **character counter** (e.g. `12/30`)

**Say (optional):** "Text fields support subtypes, max length, and live character counting."

**Show:** Counter updating as you type.

---

### Shot 3 — Validation errors (0:15 – 0:22)

**Action:**
- Clear **Campaign Name** (or leave a required field empty)
- Tap **Submit**

**Say (optional):** "Submit validates required fields and shows clear errors."

**Show:** Red error text under empty required fields; message "Please fix the errors below."

---

### Shot 4 — Fill form + multi-select (0:22 – 0:32)

**Action:**
- Fill **Campaign Name**
- Open **Ad Networks** menu → select multiple options
- Enter **Daily Budget** (e.g. `100`)
- Check **Terms of Service** checkbox
- Optionally tap **Terms of Service** link to show Safari opens

**Say (optional):** "Dropdowns track option IDs; checkboxes support clickable metadata links."

**Show:** Multi-select labels in trigger; checkbox checked.

---

### Shot 5 — Successful submit (0:32 – 0:45)

**Action:**
- Tap **Submit**
- Show **alert** with JSON payload
- Dismiss alert; scroll Xcode console to show `Form submission payload:` print

**Say (optional):** "On success, the app prints key-value pairs to the console and shows a confirmation alert."

**Show:** JSON like:
```json
{
  "accept_legal" : true,
  "ad_networks" : ["net_meta", "net_google"],
  "campaign_name" : "Summer Sale",
  "daily_budget" : "100"
}
```

---

### Shot 6 — Resilience (optional, 0:45 – 0:55)

**Action:**
- Tap **Form JSON** (DEBUG menu, top-right)
- Select **Edge Cases Form**
- Show form loads with fewer fields (no crash)

**Say (optional):** "Unknown types and malformed fields are gracefully ignored."

**Show:** Edge Case Form title; no DATE_PICKER or broken fields visible.

---

### Shot 7 — Close (0:55 – 1:00)

**Say (optional):** "Architecture details and AI collaboration log are in the README."

**Show:** Quick glimpse of project navigator or README in repo.

---

## Tips

- **Keep it under 60 seconds** — evaluators prefer concise demos
- **Console matters** — briefly show the printed JSON; it's a spec requirement
- **Don't narrate every tap** — let the UI speak; voiceover is optional
- **Use Debug build** for Form JSON menu; mention in README that Release is single-screen only

## One-line pitch (if asked)

> "DynoForm parses polymorphic JSON into SwiftUI components with MVVM, full theming, validation, and defensive decoding that skips unknown or malformed fields without crashing."
