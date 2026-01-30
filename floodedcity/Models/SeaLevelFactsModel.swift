import Foundation

struct SeaLevelFactsModel: Codable {
    let seaLevelFacts: [SeaLevelFact]

    enum CodingKeys: String, CodingKey {
        case seaLevelFacts = "SeaLevelFacts"
    }
}

struct SeaLevelFact: Codable {
    let level: Int
    let fact: String

    enum CodingKeys: String, CodingKey {
        case level = "Level"
        case fact = "Fact"
    }
}
