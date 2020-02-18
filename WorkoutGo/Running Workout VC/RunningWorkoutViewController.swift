//
//  RunningWorkoutViewController.swift
//  WorkoutGo
//
//  Created by Ashish Bansal on 28/04/19.
//  Copyright © 2019 Ashish Bansal. All rights reserved.
//

import UIKit
import AVFoundation

class RunningWorkoutViewController: UIViewController {
    
    private enum ExerciseState {
        case running
        case nonRunning
    }
    
    enum ExerciseOperation {
        case jumpToPrevious
        case jumpToNext
    }

    @IBOutlet weak var controlsContainerView: UIView!
    @IBOutlet weak var totalTimeRemainingLabel: UILabel!
    @IBOutlet weak var exercisesContainerView: ExerciseContainerView!
    
    @IBOutlet weak var playPauseButton: RoundedButtton!
    @IBOutlet weak var previousButton: RoundedButtton!
    @IBOutlet weak var nextButton: RoundedButtton!
    @IBOutlet weak var rewindButton: RoundedButtton!
    @IBOutlet weak var fastForwardButton: RoundedButtton!
    
    var exerciseInfoList: [ExerciseInfo]!
    var currentExerciseInfoIndex: Int! {
        didSet {
            currentExerciseRemainingTime = currentExerciseDuration
            updateButtonStates()
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
    
    var currentExerciseView: ExerciseCardViewContainer {
        exercisesContainerView.foregroundExerciseView
    }
    
    var currentExerciseFractionalComplete: Float {
        Float(currentExerciseDuration - currentExerciseRemainingTime) / Float(currentExerciseDuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "BlackPolygon")!)
        exercisesContainerView.initialize(withExerciseName: currentExerciseName, withDurationInSecs: currentExerciseDuration)
        configureButtonLabels()
        populateTotalExerciseTime()
        updateButtonStates()
    }
    
    private func updateButtonStates() {
        if currentExerciseInfoIndex == exerciseInfoList.startIndex {
            previousButton?.isEnabled = false
        }
        else {
            previousButton?.isEnabled = true
        }
        
        if currentExerciseInfoIndex == exerciseInfoList.lastIndex {
            nextButton?.isEnabled = false
        }
        else {
            nextButton?.isEnabled = true
        }
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
        exercisesContainerView.backgroundExerciseView.isHidden = true
        currentExerciseView.stopProgressViewAnimator()
        if exerciseTimer?.isValid ?? false {
            exerciseTimer?.invalidate()
        }
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
        exercisesContainerView.transitionExerciseView(forOperation: operation, withNewExerciseName: currentExerciseName, withDuration: currentExerciseDuration)
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
        playNextPreviousSound()
        performExerciseOperation(.jumpToPrevious)
//        if currentExerciseInfoIndex != exerciseInfoList.startIndex {
//        }
    }
    
    @IBAction func jumpToNextExercise(_ sender: RoundedButtton) {
        playNextPreviousSound()
        performExerciseOperation(.jumpToNext)
//        if let validLastIndex = exerciseInfoList.lastIndex, currentExerciseInfoIndex < validLastIndex {
//        }
    }
    
    private func adjustTotalTime(withOperation operation: ExerciseOperation) {
        let timeElapsedOfCurrentExercise = currentExerciseDuration - currentExerciseRemainingTime
        
        switch operation {
        case .jumpToNext:
            totalExerciseDurationInSecs -= currentExerciseRemainingTime
        case .jumpToPrevious:
            let indexOfPreviousExercise = exerciseInfoList.index(before: currentExerciseInfoIndex)
            let durationOfPreviousExercise = exerciseInfoList[indexOfPreviousExercise].duration
            totalExerciseDurationInSecs += timeElapsedOfCurrentExercise + durationOfPreviousExercise
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
