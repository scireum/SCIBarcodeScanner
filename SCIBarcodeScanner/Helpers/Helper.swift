import Foundation
import UIKit

class Helper {

    /// Contains the bundle holding the library's own images.
    ///
    /// Built as a Swift package, the resources live in the package's resource bundle; built via CocoaPods, they are
    /// copied into the framework, or into a `SCIBarcodeScannerView.bundle` inside it.
    private static var imageBundle: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        let bundle = Bundle(for: SCIBarcodeScannerView.self)
        return bundle.resourcePath.flatMap { Bundle(path: $0 + "/SCIBarcodeScannerView.bundle") } ?? bundle
        #endif
    }

    /// Contains the bundle holding the library's own translations.
    private static var stringsBundle: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: SCIBarcodeScannerView.self)
        #endif
    }

    /**
     Get Image from own pods bundle
     - Returns: UIImage
    */
    static func getImageFromPod(named: String, compatibleWith: UITraitCollection? = nil) -> UIImage {

        guard let image = UIImage(named: named, in: imageBundle, compatibleWith: compatibleWith) else {
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
            return self.localizedStringFrom(bundle: stringsBundle, backUpKey)
        }
    }

}

