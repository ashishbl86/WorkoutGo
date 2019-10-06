//
//  RunningWorkoutViewController.swift
//  WorkoutGo
//
//  Created by Ashish Bansal on 28/04/19.
//  Copyright © 2019 Ashish Bansal. All rights reserved.
//

import UIKit

class RunningWorkoutViewController: UIViewController, ExerciseContainerViewLayoutDelegate {
    lazy var horizontalSeparation: CGFloat = (exercisesContainerView.bounds.width - currentExerciseView.frame.width)
    
    private enum ExerciseState {
        case running
        case nonRunning
    }
    
    private enum ExerciseOperation {
        case jumpToPrevious
        case jumpToNext
    }

    func layoutSubviews(for view: ExerciseContainerView) {
        let originXCurrentExercise = (exercisesContainerView.bounds.width - currentExerciseView.frame.width)/2
        let frameOriginOfCurrentExerciseView = CGPoint(x: originXCurrentExercise, y: currentExerciseView.frame.origin.y)
        let frameOriginOfPreviousNextExerciseView = CGPoint(x: frameOriginOfCurrentExerciseView.x + currentExerciseView.frame.width + horizontalSeparation, y: frameOriginOfCurrentExerciseView.y)
        
        currentExerciseView.frame.origin = frameOriginOfCurrentExerciseView
        previousAndNextExerciseView.frame.origin = frameOriginOfPreviousNextExerciseView
    }

    @IBOutlet weak var currentExerciseNameLabel: UILabel!
    @IBOutlet weak var currentExerciseDurationLabel: UILabel!    
    @IBOutlet weak var currentExerciseProgressView: UIProgressView!
    @IBOutlet weak var previousNextExerciseNameLabel: UILabel!
    @IBOutlet weak var previousNextExerciseDurationLabel: UILabel!
    @IBOutlet weak var previousNextExerciseProgressView: UIProgressView!
    @IBOutlet weak var controlsContainerView: UIView!
    @IBOutlet weak var currentExerciseView: UIView!
    @IBOutlet weak var previousAndNextExerciseView: UIView!
    @IBOutlet weak var totalTimeRemainingLabel: UILabel!
    @IBOutlet weak var exercisesContainerView: ExerciseContainerView! {
        didSet {
            exercisesContainerView.delegate = self
        }
    }
    
    var exerciseInfoList: [ExerciseInfo]!
    var currentExerciseInfoIndex: Int! {
        didSet {
            currentExerciseRemainingTime = currentExerciseDuration
        }
    }
    private var exerciseState = ExerciseState.nonRunning
    private var currentExerciseRemainingTime = 0
    private weak var exerciseTimer: Timer?
    private var totalExerciseDurationInSecs = 0
    var progressViewAnimator: UIViewPropertyAnimator!
    
    var currentExerciseDuration: Int {
        exerciseInfoList[currentExerciseInfoIndex].duration
    }

    private func updateViewsAppearence() {
        currentExerciseView.backgroundColor = UIColor(patternImage: UIImage(named: "WhitePolygon")!)
        previousAndNextExerciseView.backgroundColor = currentExerciseView.backgroundColor
        createShadow(on: currentExerciseView)
        createShadow(on: previousAndNextExerciseView)
        view.backgroundColor = UIColor(patternImage: UIImage(named: "BlackPolygon")!)
    }
    
    private func prepareExerciseCard(withNameLabel nameLabel: UILabel, withDurationLabel durationLabel: UILabel, withProgressView progressView: UIProgressView) {
        nameLabel.text = exerciseInfoList[currentExerciseInfoIndex].name
        durationLabel.text = Globalfunc_durationFormatter(seconds: currentExerciseDuration)
        progressView.setProgress(0.0, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewsAppearence()
        populateTotalExerciseTime()
        prepareExerciseCard(withNameLabel: currentExerciseNameLabel, withDurationLabel: currentExerciseDurationLabel, withProgressView: currentExerciseProgressView)
        initiateCurrentExerciseProgressViewAnimator()
    }
    
    private func populateTotalExerciseTime() {
        exerciseInfoList.forEach { exerciseInfo in
            totalExerciseDurationInSecs += exerciseInfo.duration
        }
        totalTimeRemainingLabel.text = Globalfunc_durationFormatter(seconds: totalExerciseDurationInSecs)
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
    
    @objc private func decrementExerciseTime() {
        currentExerciseRemainingTime -= 1
        totalExerciseDurationInSecs -= 1
        currentExerciseDurationLabel.text = Globalfunc_durationFormatter(seconds: currentExerciseRemainingTime)
        totalTimeRemainingLabel.text = Globalfunc_durationFormatter(seconds: totalExerciseDurationInSecs)
        
        if currentExerciseRemainingTime == 0 {
            performExerciseOperation(.jumpToNext)
        }
    }
    
    private func initiateCurrentExerciseProgressViewAnimator() {
        if let progressViewAnimatorState = progressViewAnimator?.state, progressViewAnimatorState == .active {
            progressViewAnimator.stopAnimation(true)
        }
        
        progressViewAnimator = UIViewPropertyAnimator(duration: TimeInterval(currentExerciseDuration), curve: .linear, animations: {
            self.currentExerciseProgressView.setProgress(1.0, animated: true)
        })
    }
    
    private func toggleExercise() {
        switch exerciseState {
        case .nonRunning:
            exerciseTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(decrementExerciseTime), userInfo: nil, repeats: true)
            progressViewAnimator.startAnimation()
            exerciseState = .running
        case .running:
            exerciseTimer?.invalidate()
            progressViewAnimator.pauseAnimation()
            let progressViewFractionalComplete = Float(currentExerciseDuration - currentExerciseRemainingTime) / Float(currentExerciseDuration)
            progressViewAnimator.fractionComplete = CGFloat(progressViewFractionalComplete)
            exerciseState = .nonRunning
        }
    }
    
    @IBAction func playPauseExercise(_ sender: RoundedButtton) {
        toggleExercise()
    }
    
    private func animateCardTranstion(withOperation operation: ExerciseOperation) {
        var targetLocationOfCurrent = CGPoint.zero
        
        switch operation {
        case .jumpToPrevious:
            previousAndNextExerciseView.center = CGPoint(x: currentExerciseView.center.x - previousAndNextExerciseView.frame.width - horizontalSeparation, y: currentExerciseView.center.y)
            targetLocationOfCurrent = CGPoint(x: currentExerciseView.center.x + currentExerciseView.frame.width + horizontalSeparation, y: currentExerciseView.center.y)
            
        case .jumpToNext:
            previousAndNextExerciseView.center = CGPoint(x: currentExerciseView.center.x + previousAndNextExerciseView.frame.width + horizontalSeparation, y: currentExerciseView.center.y)
            targetLocationOfCurrent = CGPoint(x: currentExerciseView.center.x - currentExerciseView.frame.width - horizontalSeparation, y: currentExerciseView.center.y)
        }
        
        let animationDuration = 0.6
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
    
    private func performExerciseOperation(_ operation: ExerciseOperation) {
        let currentExerciseState = exerciseState
        if currentExerciseState == .running {
            toggleExercise()
        }
        adjustTotalTime(withOperation: operation)
        
        switch operation {
        case .jumpToPrevious:
            currentExerciseInfoIndex.decrement()
        case .jumpToNext:
            currentExerciseInfoIndex.increment()
        }
        prepareExerciseCard(withNameLabel: previousNextExerciseNameLabel, withDurationLabel: previousNextExerciseDurationLabel, withProgressView: previousNextExerciseProgressView)
        animateCardTranstion(withOperation: operation)
        initiateCurrentExerciseProgressViewAnimator()
        
        if currentExerciseState == .running {
            toggleExercise()
        }
    }
    
    @IBAction func jumpToPreviousExercise(_ sender: RoundedButtton) {
        performExerciseOperation(.jumpToPrevious)
    }
    
    @IBAction func jumpToNextExercise(_ sender: RoundedButtton) {
        performExerciseOperation(.jumpToNext)
    }
    
    private func adjustTotalTime(withOperation operation: ExerciseOperation) {
        let timeElapsedOfCurrentExercise = currentExerciseDuration - currentExerciseRemainingTime
        
        switch operation {
        case .jumpToNext:
            totalExerciseDurationInSecs -= currentExerciseRemainingTime
        case .jumpToPrevious:
            totalExerciseDurationInSecs += timeElapsedOfCurrentExercise + currentExerciseDuration
        }
        
        totalTimeRemainingLabel.text = Globalfunc_durationFormatter(seconds: totalExerciseDurationInSecs)
    }
    
    @IBAction func backXSecs(_ sender: RoundedButtton) {
        
    }
    
    @IBAction func fwdXSecs(_ sender: RoundedButtton) {
        
    }
}

extension Int {
    mutating func decrement() {
        self -= 1
    }
    
    mutating func increment() {
        self += 1
    }
}
