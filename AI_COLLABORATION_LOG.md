# AI Collaboration Log — DynoForm

This file documents AI-assisted development for the Eulerity take-home exercise, as required by the submission guidelines.

---

## Tools used

| Tool | Role |
|------|------|
| **ChatGPT** | Initial architecture brief — MVVM, Clean Architecture, layer responsibilities, sample JSON |
| **Claude** | Reusable SwiftUI components — failable data models + TEXT/DROPDOWN/TOGGLE/CHECKBOX views |
| **Cursor** (Agent) | Architecture scaffolding, refactors, take-home completion, quality improvements |
| **OpenAI Codex** | Architecture review and post-fix validation |

**Attached transcript:** [Transcripts/cursor_dynamic_form_rendering_architect.md](Transcripts/cursor_dynamic_form_rendering_architect.md) — full Cursor export of the early architecture and implementation thread (exported 5/24/2026)

---

## Workflow overview

1. **Architecture** (ChatGPT brief) → **UI components** (Claude) → **Full implementation** (Cursor)
2. **Architecture review** (Codex) — requirement compliance, boundaries, defensive parsing, extensibility
3. **Targeted improvements** (Cursor) — address concrete issues without over-abstracting
4. **Revalidation** (Codex) — confirm fixes and document tradeoffs

---

## Phase 0 — ChatGPT: Architecture brief

**Kept:** Layer separation, sample JSON, protocol-oriented design, per-type extensibility checklist.

**Adapted during implementation:** Central mapper removed; conversion moved to `Mapping/*FieldAPIMapper.swift`. TOGGLE added to match spec.

---

## Phase 1 — Claude: Reusable UI components

**Delivered:** Failable models (`id` + `label` required), TEXT subtypes, dropdown, toggle, checkbox with SF Symbols, character clamping, preview gallery.

**Integrated into final app:**

| Starting point (Claude) | Final DynoForm |
|-------------------------|----------------|
| Floating-label TEXT card | Label + bordered field (theme + FocusState) |
| Dropdown sheet | Picker (single) + Menu (multi) per spec |
| Standalone gallery | Wired into SDUI pipeline via `*ComponentData.fieldModel` |
| Plain checkbox | + AttributedString metadata links |

---

## Phase 2–5 — Cursor: Core implementation

**Built:** `FormRepository`, DTOs, use cases, `DynamicFormViewModel`, views, `campaign_form.json`.

**Refactors:** Per-component folders, `Mapping/*FieldAPIMapper.swift`, ID-based bindings, index-free validation, native Picker/Menu dropdowns.

---

## Phase 6–7 — Cursor: Take-home completion

**Delivered:**

- `LossyDecodableArray`, `APIFieldDTO.unknown` for defensive parsing
- `BuildFormSubmissionUseCase`, submit alert + console JSON
- `FormThemeEnvironment`, supporting text, checkbox links
- Expanded JSON payloads, unit tests, README, EDGE_CASES, DEMO_VIDEO_SCRIPT

---

## Phase 8–9 — Architecture review and improvements

**Review focus:** Requirement compliance, Clean Architecture boundaries, SDUI patterns, defensive programming, test coverage.

**Improvements implemented:**

| Area | Change |
|------|--------|
| List identity | ID-based bindings; `ForEach(components, id: \.id)` |
| Validation | `FormComponentItem.validated(using:markValidated:)` co-located with components |
| Repository boundary | `fetchFormDTO` + `ParseFormDefinitionUseCase` |
| Regex safety | `RegexPatternValidator` at mapping time |
| Duplicate fields | Deduped in `MapFormFieldsUseCase` + `FormDiagnostics` |
| UX | Blur validation, scroll to first error |
| Mapping | Consolidated under `Mapping/*FieldAPIMapper.swift` |
| Extensibility | Documented in `ADDING_A_FIELD_TYPE.md` |

**Pragmatic tradeoffs (documented, not over-built):**

- **Switch-based SDUI** instead of a plugin registry — appropriate for four field types; checklist in `ADDING_A_FIELD_TYPE.md` for adding types
- **`FormDefinition`** instead of a full DTO → Entity → Presentation stack — sufficient for this scope
- **Submit + blur validation** — avoids noisy live validation while meeting spec

---

## Phase 10 — Post-fix validation

Codex re-reviewed the codebase after Phase 9 fixes. Confirmed meaningful improvement in architecture boundaries, defensive parsing, and test coverage. Documented tradeoffs above remain intentional for take-home scope.

---

## My ownership (what I directed vs. accepted as-is)

**Directed and implemented:**

- Layer boundaries, lossy decode, submission pipeline, theming
- Scoped audit fixes — real bugs (index bindings, regex fail-open, duplicate ids) without framework abstractions
- Product decisions: validation timing, unknown-field handling, dropdown defaults

**Adapted from AI suggestions:**

- ChatGPT layer diagram → concrete Swift modules and mappers
- Claude component gallery → SDUI-integrated reusable views
- Codex boundary recommendations → `ParseFormDefinitionUseCase`, ID-based state

---

## Files by origin

| Origin | Artifacts |
|--------|-----------|
| ChatGPT | Layer diagram, protocols, sample JSON, extensibility rules |
| Claude | `TextFieldModel`, `DropdownOption`, failable init, subtype enum |
| Cursor | Full pipeline, lossy decode, submission, theming, audit fixes, tests, docs |
| Codex | Review priorities, scoped fix list, post-fix validation |

---

## Attached transcripts

| File | Description |
|------|-------------|
| [Transcripts/cursor_dynamic_form_rendering_architect.md](Transcripts/cursor_dynamic_form_rendering_architect.md) | Full Cursor Agent transcript — JSON-driven SDUI architecture, MVVM + Clean Architecture scaffolding, and initial implementation |

---

## Related docs

- [README.md](README.md) — architecture and running the app
- [ADDING_A_FIELD_TYPE.md](ADDING_A_FIELD_TYPE.md) — adding a new field type
