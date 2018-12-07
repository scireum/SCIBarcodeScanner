import UIKit
import SCIBarcodeScanner

class ViewController: UIViewController, SCIBarcodeScannerViewDelegate {

    @IBOutlet var scannerFrame: SCIBarcodeScannerView!
    @IBOutlet var torchButton: UIBarButtonItem!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.scannerFrame.delegate = self

        if !self.scannerFrame.isTorchModeAvailable {
            self.navigationItem.rightBarButtonItem = nil
        } else {
            setTorchButtonTitle()
        }
    }

    @IBAction func toggleTorch(_ sender: Any?) {
        self.scannerFrame.toggleTorch()
        setTorchButtonTitle()
    }

    private func setTorchButtonTitle() {
        guard scannerFrame.isTorchModeAvailable else { return }

        switch scannerFrame.torchMode {
        case .on:
            torchButton.title = "Torch Off"
        case .off:
            torchButton.title = "Torch On"
        }
    }

    func sciBarcodeScannerViewReceived(code: String, type: String) {
        scannerFrame.stopCapture()
        print(code)
    }

    func sciBarcodeScannerViewCanceled() {
        print("test")
    }
}
