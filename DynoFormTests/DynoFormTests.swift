import XCTest
@testable import DynoForm

final class DynoFormTests: XCTestCase {

    private let decoder = JSONDecoder()
    private let mapUseCase = MapFormFieldsUseCase()
    private let submissionUseCase = BuildFormSubmissionUseCase()

    func testDecodeSampleForm() throws {
        let data = try loadFixture(named: "sample_form")
        let dto = try decoder.decode(FormResponseDTO.self, from: data)
        let fields = dto.fields.compactMap(\.asProtocol)

        XCTAssertEqual(dto.formTitle, "Sample")
        XCTAssertEqual(fields.count, 4)
        XCTAssertEqual(mapUseCase.execute(apiFields: fields).count, 4)
    }

    func testUnknownTypeSkipped() throws {
        let data = try loadFixture(named: "unknown_type_form")
        let dto = try decoder.decode(FormResponseDTO.self, from: data)
        let fields = dto.fields.compactMap(\.asProtocol)

        XCTAssertEqual(fields.count, 1)
        XCTAssertEqual(fields.first?.id, "valid")
    }

    func testMissingFieldsDefaultsToEmpty() throws {
        let data = try loadFixture(named: "missing_fields_form")
        let dto = try decoder.decode(FormResponseDTO.self, from: data)

        XCTAssertTrue(dto.fields.isEmpty)
        XCTAssertEqual(mapUseCase.execute(apiFields: dto.fields.compactMap(\.asProtocol)).count, 0)
    }

    func testInvalidDefaultValuesFiltered() throws {
        let data = try loadFixture(named: "invalid_defaults_form")
        let dto = try decoder.decode(FormResponseDTO.self, from: data)
        let components = mapUseCase.execute(apiFields: dto.fields.compactMap(\.asProtocol))

        guard case .dropdown(let model) = components.first else {
            return XCTFail("Expected dropdown component")
        }
        XCTAssertEqual(model.defaultSelection, ["valid_id"])
    }

    func testDuplicateIDsIgnored() throws {
        let data = try loadFixture(named: "duplicate_ids_form")
        let dto = try decoder.decode(FormResponseDTO.self, from: data)
        let components = mapUseCase.execute(apiFields: dto.fields.compactMap(\.asProtocol))

        XCTAssertEqual(components.count, 2)
        XCTAssertEqual(components.map(\.id), ["field_a", "field_b"])

        guard case .text(let first) = components[0] else {
            return XCTFail("Expected text component")
        }
        XCTAssertEqual(first.label, "First")
    }

    func testInvalidRegexStrippedAtMapping() throws {
        let data = try loadFixture(named: "invalid_regex_form")
        let dto = try decoder.decode(FormResponseDTO.self, from: data)
        let components = mapUseCase.execute(apiFields: dto.fields.compactMap(\.asProtocol))

        guard case .text(let model) = components.first else {
            return XCTFail("Expected text component")
        }
        XCTAssertNil(model.rules.regexPattern)
    }

    func testInvalidRegexPatternValidator() {
        XCTAssertFalse(RegexPatternValidator.isValid("[invalid("))
        XCTAssertNil(RegexPatternValidator.sanitized("[invalid("))
        XCTAssertEqual(RegexPatternValidator.sanitized("^[A-Z]{2}$"), "^[A-Z]{2}$")
    }

    func testValidRegexEnforced() {
        let rules = FieldValidationRules(regexPattern: "^[A-Z]{2}$")
        XCTAssertFalse(FieldValidator.validate(text: "abc", rules: rules).isValid)
        XCTAssertTrue(FieldValidator.validate(text: "AB", rules: rules).isValid)
    }

    func testCheckboxDefaultValueFromAPI() throws {
        let json = """
        {"id":"agree","order":1,"type":"CHECKBOX","label":"I agree","default_value":true}
        """
        let field = try decoder.decode(CheckboxFieldAPI.self, from: Data(json.utf8))
        guard case .checkbox(let model) = field.convertToComponentModel() else {
            return XCTFail("Expected checkbox component")
        }
        XCTAssertTrue(model.defaultValue)
    }

    func testDynamicOrdering() throws {
        let data = try loadFixture(named: "ordering_form")
        let dto = try decoder.decode(FormResponseDTO.self, from: data)
        let components = mapUseCase.execute(apiFields: dto.fields.compactMap(\.asProtocol))

        XCTAssertEqual(components.map(\.id), ["first", "second", "third"])
        XCTAssertEqual(components.map(\.order), [1, 2, 3])
    }

    func testMaxLengthEnforcement() {
        let rules = FieldValidationRules(maxLength: 5)
        XCTAssertFalse(FieldValidator.validate(text: "123456", rules: rules).isValid)
        XCTAssertTrue(FieldValidator.validate(text: "12345", rules: rules).isValid)
    }

    func testSubmissionPayloadShape() {
        let textData = TextComponentData(
            id: "campaign_name",
            order: 1,
            label: "Name",
            subtype: .plain,
            placeholder: nil,
            supportingText: nil,
            maxLength: nil,
            rules: .none,
            validation: .valid
        )
        let dropdownData = DropdownComponentData(
            id: "ad_networks",
            order: 2,
            label: "Networks",
            supportingText: nil,
            options: [DropdownOption(id: "net_meta", label: "Meta")],
            maxSelect: 2,
            defaultSelection: ["net_meta"],
            rules: .none,
            validation: .valid
        )
        let checkboxData = CheckboxComponentData(
            id: "accept_legal",
            order: 3,
            label: "Accept",
            supportingText: nil,
            defaultValue: false,
            metadata: [:],
            rules: .none,
            validation: .valid
        )

        let components: [FormComponentItem] = [
            .text(textData),
            .dropdown(dropdownData),
            .checkbox(checkboxData)
        ]
        let values: [String: FieldValue] = [
            "campaign_name": .text("Summer Sale"),
            "ad_networks": .selection(["net_meta"]),
            "accept_legal": .boolean(true)
        ]

        let payload = submissionUseCase.execute(components: components, fieldValues: values)

        XCTAssertEqual(payload["campaign_name"] as? String, "Summer Sale")
        XCTAssertEqual(payload["ad_networks"] as? [String], ["net_meta"])
        XCTAssertEqual(payload["accept_legal"] as? Bool, true)
        XCTAssertNotNil(submissionUseCase.formattedJSON(components: components, fieldValues: values))
    }

    private func loadFixture(named name: String) throws -> Data {
        let bundle = Bundle(for: DynoFormTests.self)
        guard let url = bundle.url(forResource: name, withExtension: "json", subdirectory: "Fixtures")
            ?? bundle.url(forResource: name, withExtension: "json")
        else {
            throw NSError(domain: "DynoFormTests", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing fixture \(name).json"])
        }
        return try Data(contentsOf: url)
    }
}
