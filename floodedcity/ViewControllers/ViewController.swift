import MapKit
import UIKit

class POIAnnotationView: MKAnnotationView {}

class ViewController: UIViewController, MKMapViewDelegate {
    let fetchPOIAndCache = FetchPOI.shared
    var poiShowing = false
    
    // privacy policy
    @IBOutlet weak var privacyBtn: UIButton!
    @IBAction func showPrivacyPolicy(sender: UIButton) {
        let url = URL(string: "\(AppConstants.baseURL)/privacy/")!
        UIApplication.shared.open(url)
    }
    
    // flooded.city
    @IBOutlet weak var floodedCityBtn: UIButton!
    @IBAction func showFloodedCity(sender: UIButton) {
        let url = URL(string: AppConstants.baseURL)!
        UIApplication.shared.open(url)
    }
    
    @IBOutlet weak var showPOIBtn: UIButton!
    @IBAction func showPOI(sender: UIButton) {
        poiShowing = !poiShowing
        fetchAndShowPOIsForVisibleRegion()
    }
    
    // sealevel control
    // local storage for sea level
    let defaults = UserDefaults.standard
    var seaLevel: Int=1
    
    var lastPOIFetchTime: Date = .distantPast
    let poiFetchThrottle: TimeInterval = 0.5

    @IBOutlet weak var sealevelsUpBtn: UIButton!
    @IBOutlet weak var sealevelsDownBtn: UIButton!
    @IBOutlet weak var sealevelsLabel: UILabel!
    @IBOutlet weak var sealevelsFactsLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    @IBAction func changeSeaLevel(sender: UIButton) {
        var changed=false
        switch sender {
        case sealevelsUpBtn:
            sealevelsDownBtn.isEnabled = true
            // 9 or under 1m steps
            if seaLevel < 10 {
                seaLevel+=1
                changed=true
            }
            // from 10m to max data supports of 120m use 10m steps
            else if seaLevel>=10 && seaLevel < 120 {
                seaLevel+=10
                changed=true
            }
            else {
                sealevelsUpBtn.isEnabled = false
            }
            break
        case sealevelsDownBtn:
            sealevelsUpBtn.isEnabled = true
            if seaLevel>0 && seaLevel <= 10 {
                seaLevel-=1
                changed=true
            }
            else if seaLevel > 10 {
                seaLevel-=10
                changed=true
            }
            else {
                sealevelsDownBtn.isEnabled = false
            }
            break
        default:
            // required case but do nowt
            // should never hit this case
            break
            }

        if changed {displaySeaLevelsMap()}
    }

    // amount to inset overlay from the map edge.
    let standardPadding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    // Washington D.C.
    let initialRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 38.9, longitude: -77.03), span: MKCoordinateSpan(latitudeDelta: 4, longitudeDelta: 4))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        seaLevel = defaults.object(forKey: "sealevel") as? Int ?? 1
        mapView.delegate = self
        mapView.preferredConfiguration = MKStandardMapConfiguration(emphasisStyle: .muted)
        mapView.showsUserLocation = false
        mapView.showsTraffic = false
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.cameraZoomRange = MKMapView.CameraZoomRange(
                    minCenterCoordinateDistance: 30000, // Minimum zoom value
                    maxCenterCoordinateDistance: 10000000) // Max zoom value
        mapView.setRegion(initialRegion, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        displaySeaLevelsMap()
        loadMapcenterCoordinate()
        fetchAndShowPOIsForVisibleRegion()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        saveMapCenterCoordinate()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Redraw overlays if device changes between light and dark.
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            displaySeaLevelsMap()
        }
    }

    func displaySeaLevelsMap() {
        defaults.set(seaLevel, forKey: "sealevel")
        sealevelsLabel.attributedText=NSAttributedString(string: "\(seaLevel) m", attributes: seaLevelValueStrokeTextAttributes)
        removeOverlays()
        if seaLevel > 0 {
            displaySeaLevelsTiles()
        }
        // sea level changed so look for new facts, display if found for that value
        Task {
            let levelFact = await SeaLevelsFactsRequest().makeRequest(seaLevel: seaLevel)
            if levelFact.isEmpty || levelFact == "" {
                sealevelsFactsLabel.text = ""
                sealevelsFactsLabel.isHidden = true
            } else {
                sealevelsFactsLabel.attributedText=NSAttributedString(string: levelFact, attributes: seaLevelFactStrokeTextAttributes)
                sealevelsFactsLabel.isHidden = false
            }
        }
    }

    func removeOverlays() {
        let currentOverlays = mapView.overlays
        mapView.removeOverlays(currentOverlays)
    }

    func saveMapCenterCoordinate() {
        let centerCoordinate = mapView.centerCoordinate
        let lastLatitude = centerCoordinate.latitude
        let lastLongitude = centerCoordinate.longitude
        let lastZoomLevel = getZoomLevel()
        defaults.set(lastLatitude, forKey: "lastLatitude")
        defaults.set(lastLongitude, forKey: "lastLongitude")
        defaults.set(lastZoomLevel.0, forKey: "zoomLongitude")
        defaults.set(lastZoomLevel.1, forKey: "zoomLatitude")
    }

    func loadMapcenterCoordinate() {
        let lastLatitude = defaults.double(forKey: "lastLatitude")
        let lastLongitude = defaults.double(forKey: "lastLongitude")
        let newCoordinate = CLLocationCoordinate2D(latitude: lastLatitude, longitude: lastLongitude)
        let lastZoomLat = defaults.double(forKey: "zoomLatitude")
        let lastZoomLong = defaults.double(forKey: "zoomLongitude")
        if lastLatitude != 0.0 || lastLongitude != 0.0 {
            mapView.setRegion(MKCoordinateRegion(center: newCoordinate, span: MKCoordinateSpan(latitudeDelta: lastZoomLat, longitudeDelta: lastZoomLong)), animated: true)
        }
    }
    
    func getZoomLevel() -> (Double, Double) {
        let zoomLongDelta = mapView.region.span.longitudeDelta
        let zoomLatDelta = mapView.region.span.latitudeDelta
        return (zoomLongDelta, zoomLatDelta)
    }
}
