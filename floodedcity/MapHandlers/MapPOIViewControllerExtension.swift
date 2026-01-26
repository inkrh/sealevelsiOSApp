import MapKit

extension ViewController {
// MARK: POI annotations
    private func _buildPOIView(for annotation: MKAnnotation, on mapView: MKMapView) -> MKAnnotationView? {
        // Do not customize user location annotation
        if annotation is MKUserLocation {
            return nil
        }

        // Handle clustering
        if let cluster = annotation as? MKClusterAnnotation {
            let identifier = "POIClusterView"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if view == nil {
                view = MKAnnotationView(annotation: cluster, reuseIdentifier: identifier)
                view?.canShowCallout = false
            } else {
                view?.annotation = cluster
            }
            view?.displayPriority = .required
            view?.image = UIImage(named: "m3")
            return view
        }

        // Regular POI annotation view
        let identifier = "poi"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? POIAnnotationView
        
        if view == nil {
            view = POIAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
            
            view?.annotation = annotation
        }
        view?.canShowCallout = true
        view?.clusteringIdentifier = "poiCluster"

        if let poiAnno = annotation as? POIAnnotation {
            view?.image = iconForType(poiAnno.type)
    #if canImport(UIKit)
            let label = UILabel()
            label.numberOfLines = 0
            label.text = poiAnno.subtitle

            view?.detailCalloutAccessoryView = label
    #else
            view?.detailCalloutAccessoryView = nil
    #endif
        }
        view?.displayPriority = .required
        return view
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return _buildPOIView(for: annotation, on: mapView)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        if annotation is MKClusterAnnotation {
            let currentRegion = mapView.region
            let newSpan = MKCoordinateSpan(latitudeDelta: currentRegion.span.latitudeDelta / 3.0,
                                           longitudeDelta: currentRegion.span.longitudeDelta / 3.0)
            let newRegion = MKCoordinateRegion(center: annotation.coordinate, span: newSpan)
            mapView.setRegion(newRegion, animated: true)
            mapView.deselectAnnotation(annotation, animated: false)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Update POIs when the visible region changes due to user interaction or programmatic changes.
        fetchAndShowPOIsForVisibleRegion()
    }
    
    func fetchAndShowPOIsForVisibleRegion() {
        // Throttle requests to avoid spamming during pans/zooms
        let now = Date()
        guard now.timeIntervalSince(lastPOIFetchTime) > poiFetchThrottle else { return }
        lastPOIFetchTime = now
        
        let region = mapView.region
        let center = region.center
        let span = region.span
        let minLat = center.latitude - span.latitudeDelta / 2.0
        let maxLat = center.latitude + span.latitudeDelta / 2.0
        let minLon = center.longitude - span.longitudeDelta / 2.0
        let maxLon = center.longitude + span.longitudeDelta / 2.0
        
        Task { [weak self] in
            guard let self = self else { return }
//old
//            let poiLocations = await POIRequest().makeRequest(minLat: minLat, maxLat: maxLat, minLon: minLon, maxLon: maxLon)
            // cache POI once on each launch, content doesn't change much, could also move to static json
            await fetchPOIAndCache.populateCache()
            let poiLocations = await fetchPOIAndCache.getPOI(minLat: minLat, maxLat: maxLat, minLon: minLon, maxLon: maxLon)
            // Remove existing annotations before adding new ones
            let existingAnnotations = self.mapView.annotations
            self.mapView.removeAnnotations(existingAnnotations)
            var newAnnotations: [MKAnnotation] = []
            for poi in poiLocations.locations {
                let annotation = POIAnnotation(
                    coordinate: CLLocationCoordinate2D(latitude: poi.lat, longitude: poi.lon),
                    title: poi.name,
                    subtitle: poi.content+"\n"+poi.additionalContent,
                    type: poi.type.rawValue
                )
                newAnnotations.append(annotation)
            }
            self.mapView.addAnnotations(newAnnotations)
        }
    }
}
