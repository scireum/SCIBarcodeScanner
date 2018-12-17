import UIKit
import SCIBarcodeScanner

class ViewController: UIViewController {

    @IBOutlet var scannerFrame: SCIBarcodeScannerView!
    @IBOutlet var torchButton: UIBarButtonItem!


    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        self.scannerFrame.delegate = self

        if !self.scannerFrame.isTorchModeAvailable {
            self.navigationItem.rightBarButtonItem = nil
        } else {
            setTorchButtonTitle()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.scannerFrame.stopCapture()
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

    @objc private func applicationWillEnterForeground() {
        setTorchButtonTitle()
    }
}

extension ViewController: SCIBarcodeScannerViewDelegate {

    func sciBarcodeScannerViewReceived(code: String, type: String) {
        print(code)
    }

    func sciBarcodeScannerCameraError() {
        print("Camera error.")
    }

    func sciBarcodeScannerPermissionMissing() {
        print("Permission missing.")
    }
    func sciBarCodeScannerOpenSettings() {
        print("Scanner opened Settings.")
    }
}
