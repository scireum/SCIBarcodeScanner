import UIKit
import AVFoundation

public enum TorchMode {
    case on
    case off
    
    var toggle: TorchMode {
        switch self {
        case .on:
            return .off
        case .off:
            return .on
        }
    }
    
    var captureTorchMode: AVCaptureDevice.TorchMode {
        switch self {
        case .on:
            return .on
        case .off:
            return .off
        }
    }
}
