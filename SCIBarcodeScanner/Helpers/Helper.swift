import Foundation

class Helper {

    /**
     Get Image from own pods bundle
     - Returns: UIImage
    */
    static func getImageFromPod(named: String, compatibleWith: UITraitCollection? = nil) -> UIImage {

        var  bundle = Bundle(for: SCIBarcodeScannerView.self)
        if let resourceBundle = bundle.resourcePath.flatMap({ Bundle(path: $0 + "/SCIBarcodeScannerView.bundle") }) {
            bundle = resourceBundle
        }

        guard let image = UIImage(named: named, in: bundle, compatibleWith: compatibleWith) else {
            return UIImage()
        }

        return image
    }


    static func localizedString(_ key: String, comment: String? = nil) -> String {
        // Main Bundle
        let stringMainBundle = NSLocalizedString(key, tableName: "Localizable", bundle: Bundle.main, value: "", comment: comment ?? "")
        if stringMainBundle != key {
            return stringMainBundle
        } else {
            // Pods Bundle
            let stringPodsBundle = NSLocalizedString(key, tableName: "Localizable", bundle: Bundle(for: SCIBarcodeScannerView.self), value: "", comment: "")
            if stringPodsBundle != key {
                return stringPodsBundle
            }
        }
        return key
    }

}

