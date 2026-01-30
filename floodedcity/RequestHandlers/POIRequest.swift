import Foundation

class POIRequest {
    func makeRequest(minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) async -> POILocationsModel {
        // Build URL by injecting the bounds into the endpoint, replacing the placeholders
        // "{minlat}", "{minlon}", "{maxlat}", "{maxlon}".
        let urlString = "\(AppConstants.poiEndpoint)\(minLat)/\(minLon)/\(maxLat)/\(maxLon)"
        
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
            // TODO: more logging - timeout? incorrect json?
            return POIRequest.emptyPOILocations()
        }
    }

    static func parsePOILocations(from data: Data) -> POILocationsModel? {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(POILocationsModel.self, from: data)
        } catch {
            return nil
        }
    }

    // Provide a default/empty POILocations so the method can always return a value.
    static func emptyPOILocations() -> POILocationsModel {
        return POILocationsModel(locations: [])
    }
}
