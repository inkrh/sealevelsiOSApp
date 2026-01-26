// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let poiLocations = try? JSONDecoder().decode(POILocations.self, from: jsonData)

import Foundation

struct POILocations: Codable {
    let locations: [Location]

    enum CodingKeys: String, CodingKey {
        case locations = "Locations"
    }
}

// MARK: - Location
struct Location: Codable {
    let name: String
    let type: TypeEnum
    let lat, lon: Double
    let shape: Shape
    let points: [[Double]]
    let content, additionalContent: String
    let url: String
    let organization: Int

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case type = "Type"
        case lat = "Lat"
        case lon = "Lon"
        case shape = "Shape"
        case points = "Points"
        case content = "Content"
        case additionalContent = "AdditionalContent"
        case url = "URL"
        case organization = "Organization"
    }
}

enum Shape: String, Codable {
    case point = "Point"
}

// TODO: warnings here due to case length, should probably tidy this up at some point. Is still understandable, and currently only two cases used (C for cities and E for environments)
enum TypeEnum: String, Codable {
    case a = "A"
    case c = "C"
    case e = "E"
    case g = "G"
    case r = "R"
    case v = "V"
}
