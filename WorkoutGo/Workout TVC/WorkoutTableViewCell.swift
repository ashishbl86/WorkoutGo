//
//  WorkoutTableViewCell.swift
//  WorkoutGo
//
//  Created by Ashish Bansal on 24/04/19.
//  Copyright © 2019 Ashish Bansal. All rights reserved.
//

import UIKit

class WorkoutTableViewCell: UITableViewCell {
    
    @IBOutlet weak var workoutNameLabel: UILabel!
        
    var name: String {
        get {
            return workoutNameLabel.text!
        }
        set {
            workoutNameLabel.text = newValue
        }
    }
}
