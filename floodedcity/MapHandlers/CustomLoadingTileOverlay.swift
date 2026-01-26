import Foundation
import MapKit

class CustomLoadingTileOverlay: MKTileOverlay {

    private var urlSession: URLSession!

    override init(urlTemplate: String?) {
        super.init(urlTemplate: urlTemplate)
        setupURLSession()
    }

    private func setupURLSession() {
        let config = URLSessionConfiguration.default
        config.httpShouldUsePipelining = true
        config.httpMaximumConnectionsPerHost = 6
        config.urlCache = URLCache(memoryCapacity: 100_000, diskCapacity: 512_000_000)
        urlSession = URLSession(configuration: config)
    }

    override func loadTile(at path: MKTileOverlayPath) async throws -> Data {
        let urlToLoad = url(forTilePath: path)
        let result = try await urlSession.data(from: urlToLoad)
        let mapTileData = result.0
//      really hacky way to handle slow connections
        usleep(500_000)
        return mapTileData
    }
}
