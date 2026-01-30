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
        let memCache = 10*1024*1024 //10MB
        let diskCapacity = 512*1024*1024 //512MB
        config.urlCache = URLCache(memoryCapacity: memCache, diskCapacity: diskCapacity)
        urlSession = URLSession(configuration: config)
    }

    
    override func loadTile(at path: MKTileOverlayPath) async throws -> Data {
        let urlToLoad = url(forTilePath: path)
        do {
            let result: (Data, URLResponse) = try await urlSession.data(from: urlToLoad)
            let mapTileData = result.0
            //bug hunting
            if let httpResponse = result.1 as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                print("HTTP error: \(httpResponse.statusCode)")
            }
            
            return mapTileData
        } catch let urlError as URLError {
            print("URLError \(urlError.localizedDescription)")
            throw urlError
        } catch {
            print("Other error: \(error.localizedDescription)")
            throw error
        }
    }
}
