import UIKit
import AVFoundation

public enum TorchMode {
    case on
    case off

    /**
     Returns the toggled state.
     */
    var toggle: TorchMode {
        switch self {
        case .on:
            return .off
        case .off:
            return .on
        }
    }

    /**
     Returns the torch image
     */
    public var image: UIImage{
        switch self {
        case .on:
            return Helper.getImageFromPod(named: "flash")
        case .off:
            return Helper.getImageFromPod(named: "flash")
        }
    }

    /**
     Returns the matching low-level torch mode.
     */
    var captureTorchMode: AVCaptureDevice.TorchMode {
        switch self {
        case .on:
            return .on
        case .off:
            return .off
        }
    }
}
