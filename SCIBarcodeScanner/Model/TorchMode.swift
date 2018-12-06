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
