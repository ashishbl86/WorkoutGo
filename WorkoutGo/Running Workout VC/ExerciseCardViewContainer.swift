//
//  ExerciseCardViewContainer.swift
//  WorkoutGo
//
//  Created by Ashish Bansal on 06/10/19.
//  Copyright © 2019 Ashish Bansal. All rights reserved.
//

import UIKit

@IBDesignable
class ExerciseCardViewContainer: UIView {
    private var exerciseCard: ExerciseCardView!
    private var progressViewAnimator: UIViewPropertyAnimator!
    private var objectId: String {
        if progressViewAnimator != nil {
            return ObjectIdentifier(progressViewAnimator).debugDescription
        }
        else {
            return "NULL"
        }
    }
    
    var titleLabel: UILabel {
        exerciseCard.titleLabel
    }
    
    var durationLabel: UILabel {
        exerciseCard.durationLabel
    }
    
    func updateDuration(withDurationInSecs durationInSecs: Int) {
        exerciseCard.durationLabel.text = Globalfunc_durationFormatter(seconds: durationInSecs)
    }
    
    func prepareCard(withName exerciseName: String, withDurationInSecs durationInSecs: Int) {
        exerciseCard.titleLabel.text = exerciseName
        updateDuration(withDurationInSecs: durationInSecs)
        initializeProgressViewAnimator(withDuration: durationInSecs)
    }
    
    func setBackgroundColor(_ backgroundColor: UIColor) {
        exerciseCard.backgroundColor = backgroundColor
    }
    
    func startProgressViewAnimation() {
        progressViewAnimator.startAnimation()
    }
    
    func pauseProgressViewAnimation(withFractionCompletion fractionCompletion: Float) {
        progressViewAnimator.pauseAnimation()
        updateProgressView(withFractionalCompletion: fractionCompletion)
    }
    
    func updateProgressView(withFractionalCompletion fractionCompletion: Float) {
        progressViewAnimator.fractionComplete = CGFloat(fractionCompletion)
    }
    
    private func initializeProgressViewAnimator(withDuration duration: Int) {
        progressViewAnimator = UIViewPropertyAnimator(duration: TimeInterval(duration), curve: .linear, animations: {
            self.exerciseCard.progressView.setProgress(1.0, animated: true)
        })
    }
    
    func stopProgressViewAnimator() {
        if let progressViewAnimatorState = progressViewAnimator?.state, progressViewAnimatorState == .active {
            progressViewAnimator.stopAnimation(true)
        }
        exerciseCard.progressView.setProgress(0.0, animated: true)
    }
    
    private func loadExerciseCardFromXib() {
        exerciseCard = ExerciseCardView.loadViewFromXib()
        exerciseCard.frame = bounds
        addSubview(exerciseCard)
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        loadExerciseCardFromXib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadExerciseCardFromXib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        exerciseCard.frame = bounds
    }
}
