//
//  MicrophoneButton.swift
//  Speaktionary
//
//  Created by Rick Wierenga on 23/09/2018.
//  Copyright © 2018 Rick Wierenga. All rights reserved.
//

import UIKit

@IBDesignable
class MicrophoneButton: UIButton {
    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true 
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.backgroundColor = UIColor(red:0.05, green:0.45, blue:0.41, alpha:1.0)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.backgroundColor = UIColor(red:0.10, green:0.65, blue:0.59, alpha:1.0)
    }
}
