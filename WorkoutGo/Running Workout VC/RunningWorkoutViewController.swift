//
//  RunningWorkoutViewController.swift
//  WorkoutGo
//
//  Created by Ashish Bansal on 28/04/19.
//  Copyright © 2019 Ashish Bansal. All rights reserved.
//

import UIKit

class RunningWorkoutViewController: UIViewController, ExerciseContainerViewLayoutDelegate {
    let standardSpacing: CGFloat = 20

    func layoutSubviews(for view: ExerciseContainerView) {
        let frameOriginOfCurrentExerciseView = CGPoint(x: currentExerciseView.frame.origin.x, y: standardSpacing)
        let frameOriginOfNextExerciseView = CGPoint(x: frameOriginOfCurrentExerciseView.x, y: frameOriginOfCurrentExerciseView.y + currentExerciseView.frame.height + standardSpacing)
        gradientMaskView.frame = CGRect(origin: frameOriginOfNextExerciseView, size: CGSize(width: view.bounds.width, height: view.bounds.height - frameOriginOfNextExerciseView.y))
        prepareGradientMaskView()
        
        currentExerciseView.frame.origin = frameOriginOfCurrentExerciseView
        nextExerciseView.frame.origin = frameOriginOfNextExerciseView
        previous_newNext_ExerciseView.frame.origin = frameOriginOfNextExerciseView
        
        currentExerciseView.setNeedsLayout()
    }

    @IBOutlet weak var exerciseNameLabel: UILabel!
    @IBOutlet weak var exerciseDurationLabel: UILabel!    
    @IBOutlet weak var controlsContainerView: UIView!
    @IBOutlet weak var currentExerciseView: UIView!
    @IBOutlet weak var previous_newNext_ExerciseView: UIView!
    @IBOutlet weak var nextExerciseView: UIView!
    @IBOutlet weak var exercisesContainerView: ExerciseContainerView! {
        didSet {
            exercisesContainerView.delegate = self
        }
    }
    @IBOutlet weak var gradientMaskView: UIView!
    
    var exerciseInfo: ExerciseInfo!

    override func viewDidLoad() {
        super.viewDidLoad()
        createShadow(on: currentExerciseView)
        createShadow(on: nextExerciseView)        
        createControlViewShadow()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "BlackPolygon")!)
    }
    
    private func createControlViewShadow() {
        //controlsContainerView.layer.cornerRadius = 10
        controlsContainerView.layer.shadowColor = UIColor.black.cgColor
        controlsContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        controlsContainerView.layer.shadowRadius = 2
        controlsContainerView.layer.shadowOpacity = 0.4
    }
    
    private func prepareGradientMaskView() {
        gradientMaskView.backgroundColor = exercisesContainerView.backgroundColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientMaskView.bounds
        gradientLayer.colors = [UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.withAlphaComponent(1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.32)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientMaskView.layer.mask = gradientLayer
    }
    
    private func createShadow(on view: UIView) {
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 3, height: 3)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.4
    }
    
    private func removeShadow(on view:UIView) {
        view.layer.shadowColor = UIColor.clear.cgColor
    }
    
    @IBAction func jumpToPreviousExercise(_ sender: RoundedButtton) {
        //Position the previous above the current
        previous_newNext_ExerciseView.center = CGPoint(x: currentExerciseView.center.x, y: currentExerciseView.center.y - standardSpacing - currentExerciseView.frame.height)
        createShadow(on: previous_newNext_ExerciseView)
        
        let animationDuration = 0.6
        let targetLocationOfNext = CGPoint(x: nextExerciseView.center.x, y: nextExerciseView.center.y + nextExerciseView.frame.height + standardSpacing)
        let existingLocationOfCurrent = currentExerciseView.center
        let existingLocationOfNext = nextExerciseView.center
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
            self.nextExerciseView.center = targetLocationOfNext
            self.currentExerciseView.center = existingLocationOfNext
            self.previous_newNext_ExerciseView.center = existingLocationOfCurrent
        })
        
        //Reassign the views as per new roles
        let swapStorage_previous_newNext = previous_newNext_ExerciseView
        previous_newNext_ExerciseView = nextExerciseView
        nextExerciseView = currentExerciseView
        currentExerciseView = swapStorage_previous_newNext
    }
    
    @IBAction func jumpToNextExercise(_ sender: RoundedButtton) {
        //Position the new next below the next
        previous_newNext_ExerciseView.center = CGPoint(x: nextExerciseView.center.x, y: nextExerciseView.center.y + nextExerciseView.frame.height + standardSpacing)
        createShadow(on: previous_newNext_ExerciseView)
        
        let animationDuration = 0.6
        let targetLocationOfCurrent = CGPoint(x: currentExerciseView.center.x, y: currentExerciseView.center.y - standardSpacing - currentExerciseView.frame.height)
        let existingLocationOfCurrent = currentExerciseView.center
        let existingLocationOfNext = nextExerciseView.center
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
            self.currentExerciseView.center = targetLocationOfCurrent
            self.nextExerciseView.center = existingLocationOfCurrent
            self.previous_newNext_ExerciseView.center = existingLocationOfNext
        })
        
        let shadowDuration = 0.2 * animationDuration
        let shadowDelay = animationDuration - shadowDuration
        removeShadowFromView(currentExerciseView, duration: shadowDuration, delay: shadowDelay)
        
        //Reassign the views as per new roles
        let swapStorage_previous_newNext = previous_newNext_ExerciseView
        previous_newNext_ExerciseView = currentExerciseView
        currentExerciseView = nextExerciseView
        nextExerciseView = swapStorage_previous_newNext
    }
    
    private func removeShadowFromView(_ view: UIView, duration: Double, delay: Double) {
        let shadowRemovalAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.shadowColor))
        view.layer.shadowColor = UIColor.clear.cgColor
        shadowRemovalAnimation.fillMode = .backwards
        shadowRemovalAnimation.fromValue = UIColor.black.cgColor
        shadowRemovalAnimation.toValue = UIColor.clear.cgColor
        shadowRemovalAnimation.beginTime = CACurrentMediaTime() + delay
        shadowRemovalAnimation.duration = duration
        view.layer.add(shadowRemovalAnimation, forKey: "shadowRemoval")
    }
}
