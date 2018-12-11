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
}

