//
//  ExerciseContainerView.swift
//  WorkoutGo
//
//  Created by Ashish Bansal on 17/05/19.
//  Copyright © 2019 Ashish Bansal. All rights reserved.
//

import UIKit

protocol ExerciseContainerViewLayoutDelegate: AnyObject {
    func layoutSubviews(for: ExerciseContainerView)
}

class ExerciseContainerView: UIView {
    
    weak var delegate: ExerciseContainerViewLayoutDelegate?

    override func layoutSubviews() {
        super.layoutSubviews()
        assert(subviews.count == 4, "Exercise container view has unexpected count of subviews")
//        let previous_newNext_exerciseView = subviews[0]
//        let currentExerciseView = subviews[1]
//        let nextExerciseView = subviews[2]
//        let gradientMaskView = subviews[3]
//        
//        print("Exercise container view - layoutSubviews")
//        print("Container bounds: \(bounds)")
//        //print("Previous_newNext frame: \(previous_newNext_exerciseView.frame)")
//        print("current view frame: \(currentExerciseView.frame)")
//        //print("next view frame: \(nextExerciseView.frame)")
        
        delegate?.layoutSubviews(for: self)
    }
}
