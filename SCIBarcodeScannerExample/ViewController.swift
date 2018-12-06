//
//  ViewController.swift
//  SCIBarcodeScannerExample
//
//  Created by Maxim Schleicher on 06.12.18.
//  Copyright © 2018 scireum GmbH. All rights reserved.
//

import UIKit
import SCIBarcodeScanner

class ViewController: UIViewController, SCIBarcodeScannerViewDelegate {

    @IBOutlet var scannerFrame: SCIBarcodeScannerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scannerFrame.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    func sciBarcodeScannerViewReceived(code: String, type: String) {
        print(code)
    }
    
    func sciBarcodeScannerViewCanceled() {
        print("test")
    }

}

