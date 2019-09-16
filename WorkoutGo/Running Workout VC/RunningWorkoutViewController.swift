//
//  RunningWorkoutViewController.swift
//  WorkoutGo
//
//  Created by Ashish Bansal on 28/04/19.
//  Copyright © 2019 Ashish Bansal. All rights reserved.
//

import UIKit

class RunningWorkoutViewController: UIViewController, ExerciseContainerViewLayoutDelegate {
    lazy var horizontalSeparation: CGFloat = (exercisesContainerView.bounds.width - currentExerciseView.frame.width) * 2

    func layoutSubviews(for view: ExerciseContainerView) {
        let originXCurrentExercise = (exercisesContainerView.bounds.width - currentExerciseView.frame.width)/2
        let frameOriginOfCurrentExerciseView = CGPoint(x: originXCurrentExercise, y: currentExerciseView.frame.origin.y)
        let frameOriginOfPreviousNextExerciseView = CGPoint(x: frameOriginOfCurrentExerciseView.x + currentExerciseView.frame.width + horizontalSeparation, y: frameOriginOfCurrentExerciseView.y)
        
        currentExerciseView.frame.origin = frameOriginOfCurrentExerciseView
        previousAndNextExerciseView.frame.origin = frameOriginOfPreviousNextExerciseView
    }

    @IBOutlet weak var exerciseNameLabel: UILabel!
    @IBOutlet weak var exerciseDurationLabel: UILabel!    
    @IBOutlet weak var controlsContainerView: UIView!
    @IBOutlet weak var currentExerciseView: UIView!
    @IBOutlet weak var previousAndNextExerciseView: UIView!
    @IBOutlet weak var exercisesContainerView: ExerciseContainerView! {
        didSet {
            exercisesContainerView.delegate = self
        }
    }
    
    var exerciseInfo: ExerciseInfo!

    override func viewDidLoad() {
        print("Running Workout VC - viewDidLoad called")
        super.viewDidLoad()
        currentExerciseView.backgroundColor = UIColor(patternImage: UIImage(named: "WhitePolygon")!)
        previousAndNextExerciseView.backgroundColor = currentExerciseView.backgroundColor
        createShadow(on: currentExerciseView)
        createShadow(on: previousAndNextExerciseView)        
        createControlViewShadow()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "BlackPolygon")!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        previousAndNextExerciseView.isHidden = true
    }
    
    private func createControlViewShadow() {
        //controlsContainerView.layer.cornerRadius = 10
        controlsContainerView.layer.shadowColor = UIColor.black.cgColor
        controlsContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        controlsContainerView.layer.shadowRadius = 2
        controlsContainerView.layer.shadowOpacity = 0.4
    }
    
    private func createShadow(on view: UIView) {
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 3, height: 3)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.4
    }
    
    @IBAction func jumpToPreviousExercise(_ sender: RoundedButtton) {
        //Position the previous left to the current
        previousAndNextExerciseView.center = CGPoint(x: currentExerciseView.center.x - previousAndNextExerciseView.frame.width - horizontalSeparation, y: currentExerciseView.center.y)
        
        let animationDuration = 0.6
        let targetLocationOfCurrent = CGPoint(x: currentExerciseView.center.x + currentExerciseView.frame.width + horizontalSeparation, y: currentExerciseView.center.y)
        let existingLocationOfCurrent = currentExerciseView.center
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
            self.previousAndNextExerciseView.center = existingLocationOfCurrent
            self.currentExerciseView.center = targetLocationOfCurrent
        })
        
        //Reassign the views as per new roles
        let swapStorage_previous_next = previousAndNextExerciseView
        previousAndNextExerciseView = currentExerciseView
        currentExerciseView = swapStorage_previous_next
    }
    
    @IBAction func jumpToNextExercise(_ sender: RoundedButtton) {
        //Position the previous right to the current
        previousAndNextExerciseView.center = CGPoint(x: currentExerciseView.center.x + previousAndNextExerciseView.frame.width + horizontalSeparation, y: currentExerciseView.center.y)
        
        let animationDuration = 0.6
        let targetLocationOfCurrent = CGPoint(x: currentExerciseView.center.x - currentExerciseView.frame.width - horizontalSeparation, y: currentExerciseView.center.y)
        let existingLocationOfCurrent = currentExerciseView.center
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
            self.previousAndNextExerciseView.center = existingLocationOfCurrent
            self.currentExerciseView.center = targetLocationOfCurrent
        })
        
        //Reassign the views as per new roles
        let swapStorage_previous_next = previousAndNextExerciseView
        previousAndNextExerciseView = currentExerciseView
        currentExerciseView = swapStorage_previous_next
    }
}
