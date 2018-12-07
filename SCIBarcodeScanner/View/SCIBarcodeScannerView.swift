import Foundation
import UIKit
import AVFoundation

public protocol SCIBarcodeScannerViewDelegate {
    func sciBarcodeScannerViewReceived(code: String, type: String)
}

public class SCIBarcodeScannerView: UIView {
    public var delegate: SCIBarcodeScannerViewDelegate?

    private var captureSession: AVCaptureSession = AVCaptureSession()
    private var captureDevice: AVCaptureDevice?

    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var scanBox: CALayer?

    private var supportedCodeTypes: [AVMetadataObject.ObjectType]?

    private var mostRecentCode: String?

    private let metadataQueue = DispatchQueue(label: "com.scireum.scanner.metadataQueue")

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

    public func setCodesTypes(avmetaDataArray: [AVMetadataObject.ObjectType]) {
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
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCamera()
                    }
                } else {
                    print(granted)
                }
            })
        }
    }

    private func setupCamera() {
        if #available(iOS 10.0, *) {
            let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
            guard let camera = deviceDiscoverySession.devices.first else {
                print("Failed to get the camera device")
                return
            }
            self.captureDevice = camera
        } else {
            guard let camera = getDevice(position: .back) else {
                print("Failed to get the camera device")
                return
            }
            self.captureDevice = camera
        }

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

    private func getDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices()
        for device in devices {
            let deviceConverted = device
            if(deviceConverted.position == position){
                return deviceConverted
            }
        }
        return nil
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

        if let preview = self.videoPreviewLayer {
            let width: CGFloat = 280.0
            scanBox?.bounds = CGRect(origin: .zero,
                                    size: CGSize(width: width, height: width))
            scanBox?.position = preview.position
        }
    }

    public func stopCapture() {
        self.captureSession.stopRunning()
        self.torchMode = .off
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
            self.delegate?.sciBarcodeScannerViewReceived(code: code, type: type)
        }
    }

}
