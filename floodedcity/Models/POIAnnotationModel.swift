import UIKit
import MapKit

final class POIAnnotationModel: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let type: String

    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, type: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.type = type
        super.init()
    }
}
