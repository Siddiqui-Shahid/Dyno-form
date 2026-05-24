# Adding a New Field Type

DynoForm uses explicit enums and switches instead of a plugin/registry framework. That keeps the take-home easy to read and explain, but adding a type still touches a **fixed checklist** of files.

## Checklist (in order)

| Step | File / area | What to add |
|------|-------------|-------------|
| 1 | `Core/Enums/APIFieldType.swift` | `case newType` + raw value matching JSON |
| 2 | `Core/Enums/ComponentType.swift` | Matching UI type |
| 3 | `API/Models/FormResponse/<Type>/` | `*FieldAPI.swift` (Decodable only) |
| 4 | `API/Models/APIField/APIFieldDTO.swift` | Decode branch + `.unknown` fallback unchanged |
| 5 | `Mapping/<Type>FieldAPIMapper.swift` | `APIFieldProtocol` + `convertToComponentModel()` |
| 6 | `Components/<Type>/<Type>ComponentData.swift` | View data model |
| 7 | `Components/FormComponentItem.swift` | Enum case + `validated(using:markValidated:)` branch |
| 8 | `Components/<Type>/<Type>Components.swift` | SwiftUI view |
| 9 | `Presentation/Views/DynamicComponentView.swift` | One `case` in `componentBody` |
| 10 | `Domain/UseCases/BuildFormSubmissionUseCase.swift` | Payload encoding for the new value |

## What stays centralized

- **Validation rules** — `FormComponentItem.validated(using:markValidated:)` so the ViewModel does not switch per type for validation.
- **Duplicate IDs** — `MapFormFieldsUseCase` drops repeated ids.
- **Unknown JSON types** — `APIFieldDTO.unknown` is skipped before mapping.

## Intentional tradeoff

SwiftUI views still need a `switch` in `DynamicComponentView` because each type renders different controls. A single mega-registry would add indirection without much benefit at this scale (4–6 field types).
