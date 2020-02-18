//
//  ExerciseContainerView.swift
//  WorkoutGo
//
//  Created by Ashish Bansal on 17/05/19.
//  Copyright © 2019 Ashish Bansal. All rights reserved.
//

import UIKit

class ExerciseContainerView: UIView {
    
    var foregroundExerciseView: ExerciseCardViewContainer!
    var backgroundExerciseView: ExerciseCardViewContainer!
    
    //Space between the foreground and the background exercise views.
    private var horizontalSeparation: CGFloat {
        bounds.width - foregroundExerciseView.frame.width
    }
    
    func initialize(withExerciseName exerciseName: String, withDurationInSecs duration: Int) {
        let exerciseViews = subviews.compactMap { view in
            view as? ExerciseCardViewContainer
        }
        
        assert(exerciseViews.count == 2, "Exercise card subviews not available")
        foregroundExerciseView = exerciseViews[0]
        backgroundExerciseView = exerciseViews[1]
        
        foregroundExerciseView.prepareCard(withName: exerciseName, withDurationInSecs: duration)
        
        let exerciseCardBackgroundColor = UIColor(patternImage: UIImage(named: "WhitePolygon")!)
        foregroundExerciseView.setBackgroundColor(exerciseCardBackgroundColor)
        backgroundExerciseView.setBackgroundColor(exerciseCardBackgroundColor)
        createShadow(on: foregroundExerciseView)
        createShadow(on: backgroundExerciseView)
    }
    
    private func createShadow(on view: UIView) {
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 3, height: 3)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.4
    }
    
    func transitionExerciseView(forOperation operation: RunningWorkoutViewController.ExerciseOperation, withNewExerciseName exerciseName: String, withDuration duration: Int) {
        backgroundExerciseView.prepareCard(withName: exerciseName, withDurationInSecs: duration)
        foregroundExerciseView.stopProgressViewAnimator()
        
        var targetLocationOfCurrent = CGPoint.zero
        
        switch operation {
        case .jumpToPrevious:
            backgroundExerciseView.center = CGPoint(x: foregroundExerciseView.center.x - backgroundExerciseView.frame.width - horizontalSeparation, y: foregroundExerciseView.center.y)
            targetLocationOfCurrent = CGPoint(x: foregroundExerciseView.center.x + foregroundExerciseView.frame.width + horizontalSeparation, y: foregroundExerciseView.center.y)
            
        case .jumpToNext:
            backgroundExerciseView.center = CGPoint(x: foregroundExerciseView.center.x + backgroundExerciseView.frame.width + horizontalSeparation, y: foregroundExerciseView.center.y)
            targetLocationOfCurrent = CGPoint(x: foregroundExerciseView.center.x - foregroundExerciseView.frame.width - horizontalSeparation, y: foregroundExerciseView.center.y)
        }
        
        let animationDuration = 0.6
        let existingLocationOfCurrent = foregroundExerciseView.center
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
            self.backgroundExerciseView.center = existingLocationOfCurrent
            self.foregroundExerciseView.center = targetLocationOfCurrent
        })
        
        //Reassign the views as per new roles
        let swapStorage_previous_next = backgroundExerciseView
        backgroundExerciseView = foregroundExerciseView
        foregroundExerciseView = swapStorage_previous_next
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let originXCurrentExercise = (bounds.width - foregroundExerciseView.frame.width)/2
        let frameOriginOfforegroundExerciseView = CGPoint(x: originXCurrentExercise, y: foregroundExerciseView.frame.origin.y)
        let frameOriginOfPreviousNextExerciseView = CGPoint(x: frameOriginOfforegroundExerciseView.x + foregroundExerciseView.frame.width + horizontalSeparation, y: frameOriginOfforegroundExerciseView.y)
        
        foregroundExerciseView.frame.origin = frameOriginOfforegroundExerciseView
        backgroundExerciseView.frame.origin = frameOriginOfPreviousNextExerciseView
    }
}
