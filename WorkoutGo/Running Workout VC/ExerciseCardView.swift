//
//  ExerciseCardView.swift
//  WorkoutGo
//
//  Created by Ashish Bansal on 06/10/19.
//  Copyright © 2019 Ashish Bansal. All rights reserved.
//

import UIKit

@IBDesignable
class ExerciseCardView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    static func loadViewFromXib() -> ExerciseCardView {
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: String(describing:self), bundle: bundle)
        return nib.instantiate(withOwner: nil, options: nil).first as! ExerciseCardView
    }

}
