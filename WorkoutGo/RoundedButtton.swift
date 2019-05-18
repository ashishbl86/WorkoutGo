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
    let cornerRadius: CGFloat = 10
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        layer.cornerRadius = cornerRadius
        layer.shadowRadius = 5
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 3, height: 3)
        layer.shadowOpacity = 0.4
    }
}
