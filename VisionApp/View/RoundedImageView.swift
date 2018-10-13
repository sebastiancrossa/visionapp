//
//  RoundedImageView.swift
//  VisionApp
//
//  Created by Sebastian Crossa on 10/13/18.
//  Copyright © 2018 Sebastian Crossa. All rights reserved.
//

import UIKit

class RoundedImageView: UIImageView {

    override func awakeFromNib() {
        self.layer.cornerRadius = 5
    }

}
