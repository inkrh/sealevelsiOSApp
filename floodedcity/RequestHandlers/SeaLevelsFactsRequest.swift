import Foundation

class SeaLevelsFactsRequest {
    func makeRequest(seaLevel: Int) async -> String {
        let url = URL(string: "\(AppConstants.factsEndpoint)\(seaLevel)")!
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let json = try JSONDecoder().decode(SeaLevelFactsModel.self, from: data)
            let fact = json.seaLevelFacts.first?.fact ?? ""
            return fact
        } catch {
            // Log and return empty string on any failure
            print("Failed to fetch or decode sea level facts: \(error)")
            return ""
        }
    }
}

