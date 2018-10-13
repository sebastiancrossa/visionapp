//
//  ViewController.swift
//  VisionApp
//
//  Created by Sebastian Crossa on 10/13/18.
//  Copyright © 2018 Sebastian Crossa. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

enum FlashState {
    case on
    case off
}

class CameraVC: UIViewController {

    // MARK : Variable declarations
    var captureSession: AVCaptureSession!
    var output:AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var photoData: Data?
    
    var flashControlState: FlashState = .off
    
    // MARK : Outlet connections
    @IBOutlet weak var capturedImageView: RoundedImageView!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var malignoIdentifierLabel: UILabel!
    @IBOutlet weak var benignoIdentifierLabel: UILabel!
    @IBOutlet weak var identifierView: RoundedView!
    @IBOutlet weak var cameraView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        previewLayer.frame = cameraView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Tap to take image
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCameraView))
        tap.numberOfTapsRequired = 1
        
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        
        // When using the camera you always have to try to catch errors, since they are prominent here
        do {
            let input = try AVCaptureDeviceInput(device: backCamera!)
            
            if captureSession.canAddInput(input) == true {
                captureSession.addInput(input)
            }
            
            output = AVCapturePhotoOutput()
            
            if captureSession.canAddOutput(output) == true {
                captureSession.addOutput(output!)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect // Similar to the content mode in an imageView
                previewLayer.connection?.videoOrientation = .portrait
                
                cameraView.layer.addSublayer(previewLayer!)
                cameraView.addGestureRecognizer(tap)
                captureSession.startRunning()
            }
        } catch {
            debugPrint(error)
        }
        
    }
    
    @objc func didTapCameraView() {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType, kCVPixelBufferWidthKey as String: 160, kCVPixelBufferHeightKey as String: 160]
        
        settings.previewPhotoFormat = previewFormat
        
        if flashControlState == .off {
            settings.flashMode = .off
        } else {
            settings.flashMode = .on
        }
        
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func resultsMethod(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation] else { return } // VNClassificationObservation does the image analysis and throws a results
        
        for clasification in results {
            if clasification.confidence < 0.9 {
                print(clasification.identifier)
                self.benignoIdentifierLabel.text = "No reconoce"
                self.malignoIdentifierLabel.text = ""
                
                break
            } else {
                if clasification.identifier == "maligno" {
                    self.malignoIdentifierLabel.text = "\(clasification.identifier) with \(Int(clasification.confidence * 100)) %"
                    self.benignoIdentifierLabel.text = ""
                } else {
                    self.benignoIdentifierLabel.text = "\(clasification.identifier) with \(Int(clasification.confidence * 100)) %"
                    self.malignoIdentifierLabel.text = ""
                }

                break
            }
        }
    }
    
    @IBAction func flashButtonPressed(_ sender: Any) {
        switch flashControlState {
        case .off:
            flashButton.setTitle("FLASH ON", for: .normal)
            flashControlState = .on
        case .on:
            flashButton.setTitle("FLASH OFF", for: .normal)
            flashControlState = .off
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}

extension CameraVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            debugPrint(error)
        } else {
            photoData = photo.fileDataRepresentation()
            
            do {
                let model = try VNCoreMLModel(for: DefaultCustomModel_1581594473().model) // Connecting to out CoreML model
                let request = VNCoreMLRequest(model: model, completionHandler: resultsMethod)
                let handler = VNImageRequestHandler(data: photoData!)
                
                try handler.perform([request])
            } catch {
                debugPrint(error)
            }
            
            let image = UIImage(data: photoData!) // Data turns into an actual image
            self.capturedImageView.image = image
        }
    }
}
