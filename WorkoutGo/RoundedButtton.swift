//
//  RoundedButtton.swift
//  WorkoutGo
//
//  Created by Ashish Bansal on 10/05/19.
//  Copyright © 2019 Ashish Bansal. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButtton: UIButton {
    
    @IBInspectable
    let cornerRadius: CGFloat = 0
    
    let blackGradientLayer = CAGradientLayer()
    let whiteGradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blackGradientLayer.frame = bounds
        whiteGradientLayer.frame = bounds
        blackGradientLayer.cornerRadius = layer.cornerRadius
        whiteGradientLayer.cornerRadius = layer.cornerRadius
    }
    
    private func setup() {
        layer.cornerRadius = cornerRadius

        blackGradientLayer.locations = [0.0, 1.0]
        blackGradientLayer.colors = [UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor, UIColor(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor]
        layer.addSublayer(blackGradientLayer)
        
        whiteGradientLayer.locations = [0.0, 0.5, 0.5]
        whiteGradientLayer.colors = [UIColor(red: 1, green: 1, blue: 1, alpha: 0.35).cgColor, UIColor(red: 1, green: 1, blue: 1, alpha: 0.06).cgColor, UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor]
        layer.addSublayer(whiteGradientLayer)
    }
}
