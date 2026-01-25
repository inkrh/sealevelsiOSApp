import Foundation

class POIRequest {
    func makeRequest(minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) async -> POILocations {
        // Build the URL by injecting the bounds into the path, replacing the placeholders
        // "{minlat}", "{minlon}", "{maxlat}", "{maxlon}".
        let urlString = "https://flooded.city:8084/POIByBounds/\(minLat)/\(minLon)/\(maxLat)/\(maxLon)"
        guard let url = URL(string: urlString) else {
            // Return an empty/default POILocations if the URL is invalid
            return POIRequest.emptyPOILocations()
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let parsed = POIRequest.parsePOILocations(from: data) {
                return parsed
            } else {
                return POIRequest.emptyPOILocations()
            }
        } catch {
            // On network or decoding error, return an empty/default value
            return POIRequest.emptyPOILocations()
        }
    }
}

private extension POIRequest {
    static func parsePOILocations(from data: Data) -> POILocations? {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(POILocations.self, from: data)
        } catch {
            return nil
        }
    }

    // Provide a default/empty POILocations so the method can always return a value.
    static func emptyPOILocations() -> POILocations {
        return POILocations(locations: [])
    }
}
