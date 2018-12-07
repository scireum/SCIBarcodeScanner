import Foundation
import UIKit
import AVFoundation

public protocol SCIBarcodeScannerViewDelegate {
    func sciBarcodeScannerViewReceived(code: String, type: String)
    func sciBarcodeScannerViewCanceled()
}

public class SCIBarcodeScannerView: UIView {
    public var delegate: SCIBarcodeScannerViewDelegate?
    private var captureSession: AVCaptureSession = AVCaptureSession()
    private var captureDevice: AVCaptureDevice?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    private var supportedCodeTypes: [AVMetadataObject.ObjectType]?
    public var scanBox: CALayer?

    public var isTorchModeAvailable: Bool {
        get {
            guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return false }
            return device.hasTorch
        }
    }

    public var torchMode: TorchMode = .off {
        didSet {
            guard let captureDevice = self.captureDevice, captureDevice.hasTorch else { return }
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
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
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
        scanBox = CALayer()
        if let box = self.scanBox {
            box.contents = UIImage(named: "Standard")?.cgImage
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

extension SCIBarcodeScannerView: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            return
        } else {
            // Get the metadata object.
            if let metadataObj: AVMetadataMachineReadableCodeObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
                if supportedCodeTypes?.contains(metadataObj.type) ?? false {
                    if let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj) {
                        if self.scanBox?.frame.contains(barCodeObject.bounds) ?? false {
                            if metadataObj.stringValue != nil {
                                self.scanBox!.contents = UIImage(named:"Success")?.cgImage
                                self.delegate?.sciBarcodeScannerViewReceived(code: metadataObj.stringValue!, type: metadataObj.type.rawValue)
                            }
                        }
                    }
                }
            }
        }
    }
}
