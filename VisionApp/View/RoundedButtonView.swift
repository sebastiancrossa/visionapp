//
//  RoundedButtonView.swift
//  VisionApp
//
//  Created by Sebastian Crossa on 10/14/18.
//  Copyright © 2018 Sebastian Crossa. All rights reserved.
//

import UIKit

class RoundedButtonView: UIButton {

    override func awakeFromNib() {
        self.layer.cornerRadius = 5
    }

}
