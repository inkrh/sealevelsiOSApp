actor FetchPOI {
    static let shared = FetchPOI()
    private init() {
        Task {
            await populateCache()
        }
    }
    
    var cachedData: POILocations = POILocations(locations: [])
    
    func populateCache() async {
        // if anything already cached use that, not ideal but doesn't change much
        // many better ways to do this, hacky but it works
        // since doesn't change much could also move to internally hosted json
        if cachedData.locations.count > 0 {
            return
        }
        // TODO: fix the initial problem that made this approach necessary.
        // grab everything and then filter at presentation to resolve problem from slow loading on each call
        cachedData = await fetchData(minLat: -90, maxLat: 90, minLon: -180, maxLon: 180)
    }
    
    func getPOI(minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) -> POILocations {
        // filtering for presentation
        let filteredPOILcations = cachedData.locations.filter{$0.lat >= minLat && $0.lat <= maxLat && $0.lon >= minLon && $0.lon <= maxLon}
        return POILocations(locations: filteredPOILcations)
    }
    
    func fetchData(minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) async -> POILocations {
        return await POIRequest().makeRequest(minLat: minLat, maxLat: maxLat, minLon: minLon, maxLon: maxLon)
    }
}
