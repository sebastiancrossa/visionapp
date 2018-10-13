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

class CameraVC: UIViewController {

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

}

