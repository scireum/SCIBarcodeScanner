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
    private var scanBox: CALayer?
    let qrCodeFrameView = UIView()
    
    public var isTorchModeAvailable: Bool {
        get {
            guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return false }
            return device.hasTorch
        }
    }
    
    private var torchMode: TorchMode = .off {
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
        
        
        
//        if let qrCodeFrameView: UIView = qrCodeFrameView {
//            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
//            qrCodeFrameView.layer.borderWidth = 2
//            self.addSubview(qrCodeFrameView)
//            self.bringSubviewToFront(qrCodeFrameView)
//        }
        self.setupScanBox()
    }
    
    private func startCapture() {
        self.captureSession.startRunning()
        self.torchMode = .off
    }
    
    func getDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices()
        for device in devices {
            let deviceConverted = device
            if(deviceConverted.position == position){
                return deviceConverted
            }
        }
        return nil
    }
    
    public func setupScanBox() {
        scanBox = CALayer()
        if let box = self.scanBox {
            box.contents = UIImage(named: "Standard")?.cgImage
            box.contentsGravity = .resizeAspect
            self.videoPreviewLayer?.addSublayer(box)
        }
    }
}

extension SCIBarcodeScannerView: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView.frame = CGRect.zero
            return
        }
        
//        // Get the metadata object.
//        if let metadataObj: AVMetadataMachineReadableCodeObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
//            if supportedCodeTypes?.contains(metadataObj.type) ?? false {
//                // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
//                let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
//                qrCodeFrameView.frame = barCodeObject!.bounds
//
//                if metadataObj.stringValue != nil {
//                    self.delegate?.sciBarcodeScannerViewReceived(code: metadataObj.stringValue!, type: metadataObj.type.rawValue)
//                }
//            }
//        }
        
        
        else {
            // Get the metadata object.
            if let metadataObj: AVMetadataMachineReadableCodeObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
                if supportedCodeTypes?.contains(metadataObj.type) ?? false {
                    if let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj) {
                        if self.scanBox?.frame.contains(barCodeObject.bounds) ?? false {
                            if metadataObj.stringValue != nil {
                                DispatchQueue.main.sync {
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
}
