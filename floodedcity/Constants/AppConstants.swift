struct AppConstants {
    static let baseURL = "https://www.flooded.city"
    // https://flooded.city:8080/tiles/{x}/{y}/{z}/"+String(seaLevel)
    static let tileEndpoint = "\(baseURL):8080/tiles/{x}/{y}/{z}/"
    // "https://flooded.city:8084/SeaLevelFacts/" + String(seaLevel)
    static let factsEndpoint = "\(baseURL):8084/SeaLevelFacts/"
    // "https://flooded.city:8084/POIByBounds/\(minLat)/\(minLon)/\(maxLat)/\(maxLon)"
    static let poiEndpoint = "\(baseURL):8084/POIByBounds/"
    
}
