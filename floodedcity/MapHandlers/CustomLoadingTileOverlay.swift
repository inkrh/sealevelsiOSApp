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
        do {
            let result: (Data, URLResponse) = try await urlSession.data(from: urlToLoad)
            let mapTileData = result.0
            //      really hacky way to handle slow connections
//            usleep(500_000)
            //bug hunting
            if let httpResponse = result.1 as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                print("HTTP error: \(httpResponse.statusCode)")
            }
            
            return mapTileData
        } catch  let urlError as URLError {
            print("URLError \(urlError.localizedDescription)")
        } catch {
            print("Other error: \(error.localizedDescription)")
        }
        //temporary while I look at it - results in infinite loop if fails
        //but is only failing once and succeeding until map is moved? and
        //the logs show this isn't even being hit?
        //possible is all down to server bandwidth, refusing multiple connections before it gets to server-side logging?
        return try await loadTile(at: path)
    }
}
