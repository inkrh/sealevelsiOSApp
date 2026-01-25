import UIKit

public func iconForType(_ type: String) -> UIImage? {
    switch type {
    case "C": return UIImage(named: "city")
    case "E": return UIImage(named: "environment")
//    case "C": return UIImage(named: "poicity")
//    case "E": return UIImage(named: "poienviro")
    case "G": return UIImage(named: "poiglacier")
    case "L": return UIImage(named: "poilandslide")
    case "N": return UIImage(named: "poinasa")
    case "R": return UIImage(named: "poireef")
    case "V": return UIImage(named: "poivolcano")
    default:   return UIImage(named: "group")
//    default:   return UIImage(named: "poi")
    }
}
