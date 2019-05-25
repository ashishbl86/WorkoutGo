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
        delegate?.layoutSubviews(for: self)
    }
}
