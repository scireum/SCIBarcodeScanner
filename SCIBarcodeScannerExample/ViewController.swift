import UIKit
import SCIBarcodeScanner

class ViewController: UIViewController, SCIBarcodeScannerViewDelegate {

    @IBOutlet var scannerFrame: SCIBarcodeScannerView!
    @IBOutlet var torchButton: UIBarButtonItem!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.scannerFrame.delegate = self
        setTorchButtonTitle()
    }

    @IBAction func toggleTorch(_ sender: Any?) {
        self.scannerFrame.toggleTorch()
        setTorchButtonTitle()
    }

    private func setTorchButtonTitle() {
        switch scannerFrame.torchMode {
        case .on:
            torchButton.title = "Torch Off"
        case .off:
            torchButton.title = "Torch On"
        }
    }

    func sciBarcodeScannerViewReceived(code: String, type: String) {
        print(code)
    }

    func sciBarcodeScannerViewCanceled() {
        print("test")
    }
}
