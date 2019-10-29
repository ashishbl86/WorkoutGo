//
//  ExerciseTableViewCell.swift
//  WorkoutGo
//
//  Created by Ashish Bansal on 25/04/19.
//  Copyright © 2019 Ashish Bansal. All rights reserved.
//

import UIKit

class ExerciseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var exerciseNameLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
        
    var exerciseInfo: ExerciseInfo! {
        didSet {
            exerciseNameLabel.text = exerciseInfo.name
            durationLabel.text = Globalfunc_durationFormatter(seconds: exerciseInfo.duration)
        }
    }
}
