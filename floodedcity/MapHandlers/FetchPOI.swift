actor FetchPOI {
    static let shared = FetchPOI()
    private init() {
        Task {
            await populateCache()
        }
    }
    
    var cachedData: POILocations = POILocations(locations: [])
    
    func populateCache() async {
        if cachedData.locations.count > 0 {
            return
        }
        cachedData = await fetchData(minLat: -90, maxLat: 90, minLon: -180, maxLon: 180)
    }
    
    func getPOI(minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) -> POILocations {
        let filteredPOILcations = cachedData.locations.filter{$0.lat >= minLat && $0.lat <= maxLat && $0.lon >= minLon && $0.lon <= maxLon}
        return POILocations(locations: filteredPOILcations)
    }
    
    func fetchData(minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) async -> POILocations {
        return await POIRequest().makeRequest(minLat: minLat, maxLat: maxLat, minLon: minLon, maxLon: maxLon)
    }
}
