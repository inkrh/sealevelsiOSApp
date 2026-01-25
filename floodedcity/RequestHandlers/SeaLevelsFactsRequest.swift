import Foundation
import SwiftyJSON

class SeaLevelsFactsRequest {
    func makeRequest(seaLevel: Int) async -> String {
        let url = URL(string: "https://flooded.city:8084/SeaLevelFacts/" + String(seaLevel))!
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = JSON(data)
            let fact = json["SeaLevelFacts"][0]["Fact"].string ?? ""
            return fact
        } catch {
            // Log and return empty string on any failure
            print("Failed to fetch or decode sea level facts: \(error)")
            return ""
        }
    }
}
