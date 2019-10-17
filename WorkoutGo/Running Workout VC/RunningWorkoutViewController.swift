//
//  RunningWorkoutViewController.swift
//  WorkoutGo
//
//  Created by Ashish Bansal on 28/04/19.
//  Copyright © 2019 Ashish Bansal. All rights reserved.
//

import UIKit
import AVFoundation

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

    @IBOutlet weak var controlsContainerView: UIView!
    @IBOutlet weak var currentExerciseView: ExerciseCardViewContainer!
    @IBOutlet weak var previousAndNextExerciseView: ExerciseCardViewContainer!
    @IBOutlet weak var totalTimeRemainingLabel: UILabel!
    @IBOutlet weak var exercisesContainerView: ExerciseContainerView! {
        didSet {
            exercisesContainerView.delegate = self
        }
    }
    
    @IBOutlet weak var playPauseButton: RoundedButtton!
    @IBOutlet weak var previousButton: RoundedButtton!
    @IBOutlet weak var nextButton: RoundedButtton!
    @IBOutlet weak var rewindButton: RoundedButtton!
    @IBOutlet weak var fastForwardButton: RoundedButtton!
    
    var exerciseInfoList: [ExerciseInfo]!
    var currentExerciseInfoIndex: Int! {
        didSet {
            currentExerciseRemainingTime = currentExerciseDuration
        }
    }
    
    var jumpSizeInSecs: Int {
        min(30, currentExerciseDuration/4)
    }
    
    private var exerciseState = ExerciseState.nonRunning
    private var currentExerciseRemainingTime = 0
    private weak var exerciseTimer: Timer?
    private var totalExerciseDurationInSecs = 0
    private let playImage = UIImage(named: "Icons/play")
    private let pauseImage = UIImage(named: "Icons/pause")
    private let playSound: AVAudioPlayer? = {
        if let sound = NSDataAsset(name: "Sounds/play") {
            if let audio = try? AVAudioPlayer(data: sound.data) {
                return audio
            }
        }
        return nil
    }()
    
    private let pauseSound: AVAudioPlayer? = {
        if let sound = NSDataAsset(name: "Sounds/pause") {
            if let audio = try? AVAudioPlayer(data: sound.data) {
                return audio
            }
        }
        return nil
    }()
    
    private let countdownSound: AVAudioPlayer? = {
        if let sound = NSDataAsset(name: "Sounds/currentExerciseEnd") {
            if let audio = try? AVAudioPlayer(data: sound.data) {
                return audio
            }
        }
        return nil
    }()
    
    private let nextPreviousSound: AVAudioPlayer? = {
        if let sound = NSDataAsset(name: "Sounds/nextPreviousJump") {
            if let audio = try? AVAudioPlayer(data: sound.data) {
                return audio
            }
        }
        return nil
    }()
    
    var currentExerciseName: String {
        exerciseInfoList[currentExerciseInfoIndex].name
    }
    
    var currentExerciseDuration: Int {
        exerciseInfoList[currentExerciseInfoIndex].duration
    }
    
    var currentExerciseNameLabel: UILabel {
        currentExerciseView.titleLabel
    }
    
    var currentExerciseDurationLabel: UILabel {
        currentExerciseView.durationLabel
    }
    
    var currentExerciseFractionalComplete: Float {
        Float(currentExerciseDuration - currentExerciseRemainingTime) / Float(currentExerciseDuration)
    }

    private func updateViewsAppearence() {
        let exerciseCardBackgroundColor = UIColor(patternImage: UIImage(named: "WhitePolygon")!)
        currentExerciseView.setBackgroundColor(exerciseCardBackgroundColor)
        previousAndNextExerciseView.setBackgroundColor(exerciseCardBackgroundColor)
        createShadow(on: currentExerciseView)
        createShadow(on: previousAndNextExerciseView)
        view.backgroundColor = UIColor(patternImage: UIImage(named: "BlackPolygon")!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButtonLabels()
        updateViewsAppearence()
        populateTotalExerciseTime()
        currentExerciseView.prepareCard(withName: currentExerciseName, withDurationInSecs: currentExerciseDuration)
    }
    
    private func configureButtonLabels() {
        playPauseButton.imageView?.contentMode = .scaleAspectFit
        previousButton.imageView?.contentMode = .scaleAspectFit
        nextButton.imageView?.contentMode = .scaleAspectFit
        rewindButton.imageView?.contentMode = .scaleAspectFit
        fastForwardButton.imageView?.contentMode = .scaleAspectFit
        
        let imageEdgeInsetPoints = CGFloat(20)
        let imageEdgeInset = UIEdgeInsets(top: imageEdgeInsetPoints, left: 0, bottom: imageEdgeInsetPoints, right: 0)
        playPauseButton.imageEdgeInsets = imageEdgeInset
        previousButton.imageEdgeInsets = imageEdgeInset
        nextButton.imageEdgeInsets = imageEdgeInset
        rewindButton.imageEdgeInsets = imageEdgeInset
        fastForwardButton.imageEdgeInsets = imageEdgeInset
    }
    
    private func populateTotalExerciseTime() {
        exerciseInfoList.forEach { exerciseInfo in
            totalExerciseDurationInSecs += exerciseInfo.duration
        }
        totalTimeRemainingLabel.text = Globalfunc_durationFormatter(seconds: totalExerciseDurationInSecs)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        previousAndNextExerciseView.isHidden = true
        currentExerciseView.stopProgressViewAnimator()
        if exerciseTimer?.isValid ?? false {
            exerciseTimer?.invalidate()
        }
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
        currentExerciseView.updateDuration(withDurationInSecs: currentExerciseRemainingTime)
        totalTimeRemainingLabel.text = Globalfunc_durationFormatter(seconds: totalExerciseDurationInSecs)
        
        if currentExerciseRemainingTime == 5 {
            countdownSound?.play()
        }
        
        if currentExerciseRemainingTime == 0 {
            performExerciseOperation(.jumpToNext)
        }
    }
    
    private func toggleExercise(withSound playSounds: Bool = true) {
        switch exerciseState {
        case .nonRunning:
            exerciseTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(decrementExerciseTime), userInfo: nil, repeats: true)
            currentExerciseView.startProgressViewAnimation()
            exerciseState = .running
            playPauseButton.setImage(pauseImage, for: .normal)
            playPauseButton.changeBackgroundColor(to: .systemRed)
            if playSounds {
                playSound?.play()
            }
        case .running:
            exerciseTimer?.invalidate()
            currentExerciseView.pauseProgressViewAnimation(withFractionCompletion: currentExerciseFractionalComplete)
            exerciseState = .nonRunning
            playPauseButton.setImage(playImage, for: .normal)
            playPauseButton.changeBackgroundColor(to: .systemGreen)
            if playSounds {
                pauseSound?.play()
            }
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
        let exerciseStateAtStartOfOperation = exerciseState
        if exerciseStateAtStartOfOperation == .running {
            toggleExercise(withSound: false)
        }
        adjustTotalTime(withOperation: operation)
        
        switch operation {
        case .jumpToPrevious:
            exerciseInfoList.formIndex(before: &currentExerciseInfoIndex)
        case .jumpToNext:
            exerciseInfoList.formIndex(after: &currentExerciseInfoIndex)
        }
        previousAndNextExerciseView.prepareCard(withName: currentExerciseName, withDurationInSecs: currentExerciseDuration)
        animateCardTranstion(withOperation: operation)
        previousAndNextExerciseView.stopProgressViewAnimator()
        if exerciseStateAtStartOfOperation == .running {
            toggleExercise(withSound: false)
        }
    }
    
    fileprivate func playNextPreviousSound() {
        if countdownSound?.isPlaying ?? false {
            countdownSound?.stop()
        }
        nextPreviousSound?.play()
    }
    
    @IBAction func jumpToPreviousExercise(_ sender: RoundedButtton) {
        if currentExerciseInfoIndex != exerciseInfoList.startIndex {
            playNextPreviousSound()
            performExerciseOperation(.jumpToPrevious)
        }
    }
    
    @IBAction func jumpToNextExercise(_ sender: RoundedButtton) {
        if let validLastIndex = exerciseInfoList.lastIndex, currentExerciseInfoIndex < validLastIndex {
            playNextPreviousSound()
            performExerciseOperation(.jumpToNext)
        }
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
        let currentExerciseElapsedTime = currentExerciseDuration - currentExerciseRemainingTime
        if currentExerciseElapsedTime > jumpSizeInSecs {
            currentExerciseRemainingTime += jumpSizeInSecs
            totalExerciseDurationInSecs += jumpSizeInSecs
            currentExerciseView.updateDuration(withDurationInSecs: currentExerciseRemainingTime)
            currentExerciseView.updateProgressView(withFractionalCompletion: currentExerciseFractionalComplete)
            totalTimeRemainingLabel.text = Globalfunc_durationFormatter(seconds: totalExerciseDurationInSecs)
        }
    }
    
    @IBAction func fwdXSecs(_ sender: RoundedButtton) {
        if currentExerciseRemainingTime > jumpSizeInSecs {
            currentExerciseRemainingTime -= jumpSizeInSecs
            totalExerciseDurationInSecs -= jumpSizeInSecs
            currentExerciseView.updateDuration(withDurationInSecs: currentExerciseRemainingTime)
            currentExerciseView.updateProgressView(withFractionalCompletion: currentExerciseFractionalComplete)
            totalTimeRemainingLabel.text = Globalfunc_durationFormatter(seconds: totalExerciseDurationInSecs)
        }
    }
}

extension Array {
    var lastIndex: Array.Index? {
        if isEmpty {
            return nil
        }
        else {
            var lastIndexBeingCalculated = endIndex
            formIndex(before: &lastIndexBeingCalculated)
            return lastIndexBeingCalculated
        }
    }
}
