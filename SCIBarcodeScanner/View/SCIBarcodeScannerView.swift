import Foundation
import UIKit
import AVFoundation

public protocol SCIBarcodeScannerViewDelegate {
    func sciBarcodeScannerViewReceived(code: String, type: String)
    func sciBarcodeScannerCanceledPermissions()
}

public class SCIBarcodeScannerView: UIView {
    public var delegate: SCIBarcodeScannerViewDelegate?

    public var alertTitle: String = "Camera Access"
    public var alertMessage: String = "In order for the barcode scanner to work, please allow access to the camera in the settings."
    public var alertCancel: String = "Cancel"
    public var alertConfirm: String = "Settings"

    private var captureSession: AVCaptureSession = AVCaptureSession()
    private var captureDevice: AVCaptureDevice?

    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var scanBox: CALayer?

    private var supportedCodeTypes: [AVMetadataObject.ObjectType]?

    private var mostRecentCode: String?

    private let metadataQueue = DispatchQueue(label: "com.scireum.scanner.metadataQueue")

    private var timer: Timer?

    private var standardImage: UIImage?
    private var successImage: UIImage?

    public var isTorchModeAvailable: Bool {
        get {
            guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return false }
            return device.hasTorch && device.isTorchAvailable
        }
    }

    public var torchMode: TorchMode = .off {
        didSet {
            // make sure that we have a device...
            guard let captureDevice = self.captureDevice else { return }

            // ...with a torch that is available...
            guard captureDevice.hasTorch, captureDevice.isTorchAvailable else { return }

            // ...and that supports the given mode
            guard captureDevice.isTorchModeSupported(torchMode.captureTorchMode) else { return }

            do {
                try captureDevice.lockForConfiguration()
                captureDevice.torchMode = torchMode.captureTorchMode
                captureDevice.unlockForConfiguration()
            } catch {}
        }
    }

    public func setCodeTypes(avmetaDataArray: [AVMetadataObject.ObjectType]) {
        self.supportedCodeTypes = avmetaDataArray
    }

    private func setupCodeTypes() {
        if self.supportedCodeTypes == nil {
            self.supportedCodeTypes = AVMetadataObject.ObjectType.all
        }
    }

    public override func willMove(toSuperview newSuperview: UIView?) {
        self.setupCodeTypes()
        self.checkPermissions()
    }

    public func toggleTorch() {
        self.torchMode = self.torchMode.toggle
    }

    private func checkPermissions() {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            setupCamera()
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] (granted: Bool) in
                if granted {
                    DispatchQueue.main.async {
                        guard let this = self else { return }
                        this.setupCamera()
                    }
                } else {
                    let alert = UIAlertController(title: self?.alertTitle,
                                                  message: self?.alertMessage,
                                                  preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: self?.alertConfirm, style: UIAlertAction.Style.default, handler: { (action) in
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: { (success) in
                                print("Scanner opened settings")
                            })
                        }
                    }))
                    alert.addAction(UIAlertAction(title: self?.alertCancel, style: UIAlertAction.Style.cancel, handler: { (action) in
                        guard let this = self else { return }
                        DispatchQueue.main.async {
                            this.delegate?.sciBarcodeScannerCanceledPermissions()
                        }
                    }))
                    DispatchQueue.main.async {
                        guard let this = self else { return }
                        guard let currentVC = this.currentTopViewController  else {
                            print("Could not load current top view controller, also could not show alert")
                            return
                        }
                        currentVC.present(alert, animated: true, completion: nil)
                    }
                }
            })
        }
    }

    private func setupCamera() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        guard let camera = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        self.captureDevice = camera

        do {

            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: self.captureDevice!)

            // Set the input device on the capture session.
            self.captureSession.addInput(input)

            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            self.captureSession.addOutput(captureMetadataOutput)

            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: self.metadataQueue)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes

        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }

        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.videoPreviewLayer?.frame = self.layer.bounds
        self.layer.addSublayer(self.videoPreviewLayer!)

        self.startCapture()
        self.setupScanBox()
    }

    private func startCapture() {
        self.captureSession.startRunning()
        self.torchMode = .off
    }

    private func setupScanBox() {
        let bundle = Bundle(for: type(of: self))
        standardImage = UIImage(named: "Standard", in: bundle, compatibleWith: nil)
        successImage = UIImage(named: "Success", in: bundle, compatibleWith: nil)

        scanBox = CALayer()
        if let box = self.scanBox {
            box.contents = standardImage?.cgImage
            box.contentsGravity = .resizeAspect
            self.videoPreviewLayer?.addSublayer(box)
        }

        self.layoutScanBox()
    }

    public func stopCapture() {
        self.captureSession.stopRunning()
        self.torchMode = .off
    }

    private func layoutScanBox() {
        if let preview = self.videoPreviewLayer {
            let width: CGFloat = 280.0
            scanBox?.bounds = CGRect(origin: .zero,
                                    size: CGSize(width: width, height: width))
            scanBox?.position = preview.position
        }
    }

    public override func layoutSubviews() {
        self.rotateVideoLayer()
    }

    private func rotateVideoLayer() {
        switch UIDevice.current.orientation {
        case .portrait:
            self.videoPreviewLayer?.transform = CATransform3DMakeRotation(0.degreesToRadians, 0, 0, 1)
        case .landscapeLeft:
            self.videoPreviewLayer?.transform = CATransform3DMakeRotation(270.degreesToRadians, 0, 0, 1)
        case .landscapeRight:
            self.videoPreviewLayer?.transform = CATransform3DMakeRotation(90.degreesToRadians, 0, 0, 1)
        case .portraitUpsideDown:
            self.videoPreviewLayer?.transform = CATransform3DMakeRotation(180.degreesToRadians, 0, 0, 1)
        default:
            self.videoPreviewLayer?.transform = CATransform3DMakeRotation(0.degreesToRadians, 0, 0, 1)
        }
        self.videoPreviewLayer?.frame = self.layer.bounds

//        guard let videoLayer = self.videoPreviewLayer else { return }
//        videoLayer.frame = self.layer.bounds
//
//        if let connection = videoLayer.connection, connection.isVideoOrientationSupported {
//            switch UIDevice.current.orientation {
//                case .portrait: connection.videoOrientation = .portrait
//                case .landscapeRight: connection.videoOrientation = .landscapeRight
//                case .landscapeLeft: connection.videoOrientation = .landscapeLeft
//                case .portraitUpsideDown: connection.videoOrientation = .portraitUpsideDown
//                default: connection.videoOrientation = .portrait
//            }
//        }
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension SCIBarcodeScannerView: AVCaptureMetadataOutputObjectsDelegate {

    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // check if the metadata objects array contains at least one sample, and obtain the most recent one
        guard let metadataObj = metadataObjects.last as? AVMetadataMachineReadableCodeObject else { return }

        // obtain the type, and make sure that we support it
        let barcodeType = metadataObj.type
        let type = barcodeType.rawValue
        guard supportedCodeTypes?.contains(barcodeType) == true else { return }

        // obtain the code, and make sure that we haven't already seen it
        guard let code = metadataObj.stringValue, mostRecentCode != code else { return }

        // make sure that the code is within the hot area
        guard let barcodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj), self.scanBox?.frame.contains(barcodeObject.bounds) == true else { return }

        // store the code as the most recent one
        mostRecentCode = code

        DispatchQueue.main.async {
            self.scanBox!.contents = self.successImage?.cgImage
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

            if nil == self.timer {
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] (timer) in
                    // reset the timer again
                    self?.timer?.invalidate()
                    self?.timer = nil

                    // forward the result to the delegate
                    self?.delegate?.sciBarcodeScannerViewReceived(code: code, type: type)

                    // reset the overlay
                    self?.scanBox!.contents = self?.standardImage?.cgImage
                }
            }
        }
    }
}
