import MapKit
import UIKit
import ObjectiveC

extension ViewController {
    // MARK: map tiles

    // Loading indicator for map tile loading state
    private static var loadingIndicatorKey: UInt8 = 0

    private var loadingIndicator: UIActivityIndicatorView {
        if let indicator = objc_getAssociatedObject(self, &Self.loadingIndicatorKey) as? UIActivityIndicatorView {
            return indicator
        }
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        objc_setAssociatedObject(self, &Self.loadingIndicatorKey, indicator, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return indicator
    }

    private func ensureLoadingIndicatorAdded() {
        guard loadingIndicator.superview == nil else { return }
        // Ensure mapView exists and is part of the view hierarchy
        guard let mapView = self.mapView else { return }
        mapView.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: mapView.centerYAnchor)
        ])
    }

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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Provide a default renderer for overlays; extend as needed for specific overlay types.
        if let tileOverlay = overlay as? MKTileOverlay {
            return MKTileOverlayRenderer(tileOverlay: tileOverlay)
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    
    //tile loading error handling
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
//        print("Map tiles finished loading for the current view.")
        // Perform actions here, e.g., show annotations or hide a loading indicator.
        loadingIndicator.stopAnimating()
    }

    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
//        print("Map is starting to load tiles.")
        // Show a loading indicator.
        ensureLoadingIndicatorAdded()
        loadingIndicator.startAnimating()
    }

    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        print("Map failed to load with error: \(error.localizedDescription)")
        loadingIndicator.stopAnimating()
        
        //TODO: refresh button to attempt reload - failing without actual error
        
        //Likely timeout, but server logs show all calls received succeeding, probably timing with presentation layer being visible rather than server?
        //Might be down to Apple's internal networking handling - logs show socket failure, so failing before it reaches server == timing?
        //Might also be down to using a non-standard port
        
        //Both of these attempts fail silently
        //1
//        displaySeaLevelsMap()
        //2
//        if let overlay = self.mapView.overlays.first(where: { $0 is MKTileOverlay }) as? MKTileOverlay {
//            if let renderer = self.mapView.renderer(for: overlay) as? MKTileOverlayRenderer {
//                renderer.reloadData()
//            }
//        }

    }

}
