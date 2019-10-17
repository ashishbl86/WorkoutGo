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
    var cornerRadius: CGFloat = 0
    var defaultBackgroundColor: UIColor!  {
        didSet {
            computeHightlightedBackgroundColor()
        }
    }
    var highlightedBackgroundColor: UIColor!
    
//    let blackGradientLayer = CAGradientLayer()
//    let whiteGradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private var backgroundColorAsPerState: UIColor? {
        isHighlighted ? highlightedBackgroundColor : defaultBackgroundColor
    }

    override var isHighlighted: Bool {
        didSet {
            if defaultBackgroundColor != nil {
                backgroundColor = backgroundColorAsPerState
            }
        }
    }
    
    private func computeHightlightedBackgroundColor() {
        if let backgroundColor = defaultBackgroundColor {
            var backgroundColorHue = CGFloat.zero
            var backgroundColorSaturation = CGFloat.zero
            var backgroundColorBrightness = CGFloat.zero
            var backgroundColorAlpha = CGFloat.zero
            
            backgroundColor.getHue(&backgroundColorHue, saturation: &backgroundColorSaturation, brightness: &backgroundColorBrightness, alpha: &backgroundColorAlpha)
            backgroundColorBrightness *= 0.9
            backgroundColorAlpha *= 0.7
            highlightedBackgroundColor = UIColor(hue: backgroundColorHue, saturation: backgroundColorSaturation, brightness: backgroundColorBrightness, alpha: backgroundColorAlpha)
        }
        else {
            highlightedBackgroundColor = nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        defaultBackgroundColor = backgroundColor
    }
    
    func changeBackgroundColor(to newBackgroundColor: UIColor) {
        defaultBackgroundColor = newBackgroundColor
        backgroundColor = backgroundColorAsPerState
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        blackGradientLayer.frame = bounds
//        whiteGradientLayer.frame = bounds
//        blackGradientLayer.cornerRadius = layer.cornerRadius
//        whiteGradientLayer.cornerRadius = layer.cornerRadius
//    }
    
    private func setup() {
        layer.cornerRadius = cornerRadius

//        blackGradientLayer.locations = [0.0, 1.0]
//        blackGradientLayer.colors = [UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor, UIColor(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor]
//        layer.addSublayer(blackGradientLayer)
//
//        whiteGradientLayer.locations = [0.0, 0.5, 0.5]
//        whiteGradientLayer.colors = [UIColor(red: 1, green: 1, blue: 1, alpha: 0.35).cgColor, UIColor(red: 1, green: 1, blue: 1, alpha: 0.06).cgColor, UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor]
//        layer.addSublayer(whiteGradientLayer)
    }
}
