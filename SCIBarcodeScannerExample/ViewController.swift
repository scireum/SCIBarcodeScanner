import UIKit
import SCIBarcodeScanner

class ViewController: UIViewController, SCIBarcodeScannerViewDelegate {

    @IBOutlet var scannerFrame: SCIBarcodeScannerView!
    @IBOutlet var torchButton: UIBarButtonItem!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.scannerFrame.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func toggleTorch(_ sender: Any?) {
    }

    func sciBarcodeScannerViewReceived(code: String, type: String) {
        print(code)
    }

    func sciBarcodeScannerViewCanceled() {
        print("test")
    }
}
