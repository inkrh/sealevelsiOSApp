import Foundation
import MapKit

// should probably be its own class
extension ViewController {
    func floodedCityTilePathTemplate(seaLevel: Int) -> String {
        return "\(AppConstants.tileEndpoint)\(seaLevel)"
    }

    func displaySeaLevelsTiles() {
         // The URL template contains tokens for tile path parameters, which the system substitutes with specific tile path values when loading them.
         // flooded.city accepts x,y,z, and s where s==sealevel height in m
         // https://flooded.city:8080/tiles/{x}/{y}/{z}/{s}
         // e.g. https://flooded.city:8080/tiles/15/27/6/1
        let floodedCityTilePath = floodedCityTilePathTemplate(seaLevel: seaLevel)
        let floodedCityTileOverlay = MKTileOverlay(urlTemplate: floodedCityTilePath)
        mapView.addOverlay(floodedCityTileOverlay, level: .aboveRoads)
    }

    func createTileRenderer(for overlay: MKTileOverlay) -> MKTileOverlayRenderer {
         // For tile overlays, there's little need to subclass the overlay renderer, unlike other types of custom overlays.
         // This sample always uses the default tile renderer implementation.
        let tileRenderer = MKTileOverlayRenderer(tileOverlay: overlay)
        return tileRenderer
    }
}
