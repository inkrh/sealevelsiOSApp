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
        //TODO: When fails this is being triggered, without hitting didFail
        //Fix by handling in CustomLoadingTileOverlay - check pending queue?
        loadingIndicator.stopAnimating()
    }

    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        ensureLoadingIndicatorAdded()
        loadingIndicator.startAnimating()
    }

    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        print("Map failed to load with error: \(error.localizedDescription)")
        loadingIndicator.stopAnimating()
        
        //TODO: refresh button to attempt reload? Failing without actual error
        //this isn't being hit on initial load error?
        //server logs show all calls received succeeding, probably timing with presentation?
        

    }

}
