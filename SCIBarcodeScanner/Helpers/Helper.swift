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


    static func localizedStringFrom(bundle: Bundle ,_ key: String, comment: String? = nil) -> String {
        let stringFromBundle = NSLocalizedString(key, tableName: "Localizable", bundle: bundle, value: "", comment: comment ?? "")
        if stringFromBundle != key {
            return stringFromBundle
        }
        return key
    }

    static func getLocalizedStringFrom(key: String?, backUpKey: String) -> String {
        if let keyString: String = key{
            return self.localizedStringFrom(bundle: Bundle.main, keyString)
        } else {
            return self.localizedStringFrom(bundle: Bundle.init(for: SCIBarcodeScannerView.self), backUpKey)
        }
    }

}

