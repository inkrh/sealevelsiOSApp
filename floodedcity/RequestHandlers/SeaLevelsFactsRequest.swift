import Foundation
import SwiftyJSON

//TODO: move to built in decoder, SwiftyJSON is great, but is too heavy to just pull one string from the returned data
class SeaLevelsFactsRequest {
    func makeRequest(seaLevel: Int) async -> String {
        let url = URL(string: "\(AppConstants.factsEndpoint)\(seaLevel)")!
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
