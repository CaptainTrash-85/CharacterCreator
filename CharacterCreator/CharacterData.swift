import Foundation

// MARK: - Data model for characterData.json
struct CharacterData: Codable {
    let ages: [String]
    let ethnicities: [String]
    let skinTones: [String]
    let bodyTypes: [String]
    let faceShapes: [String]
    let eyeColors: [String]

    let makeups: [String]?
    let breastSizes: [String]?

    let facialHair: [String]?

    let expressions: [String]

    let hairstyles: [String: [String]]

    let hairColors: [String]
    let cameras: [String]
    let environments: [String]
    let lightings: [String]
    let accessories: [String]

    let poseCategories: [String: [String]]

    let clothingCategories: [String: ClothingCategory]
}

// MARK: - ClothingCategory
enum ClothingCategory: Codable {
    case items([String])
    case subcategories([String: [String]])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let arr = try? container.decode([String].self) {
            self = .items(arr)
        } else if let dict = try? container.decode([String: [String]].self) {
            self = .subcategories(dict)
        } else {
            throw DecodingError.typeMismatch(
                ClothingCategory.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Neither array nor dictionary recognized"
                )
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .items(let arr):
            try container.encode(arr)
        case .subcategories(let dict):
            try container.encode(dict)
        }
    }
}

