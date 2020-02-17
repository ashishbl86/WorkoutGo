//
//  StartWorkoutTransitionAnimator.swift
//  WorkoutGo
//
//  Created by Ashish Bansal on 16/02/20.
//  Copyright © 2020 Ashish Bansal. All rights reserved.
//

import UIKit

class StartWorkoutTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private var selectedTableCell: ExerciseTableViewCell
    private var animationBaseView: UIView!
    private let completionTask: () -> Void
    
    init(selectedTableCell: ExerciseTableViewCell, completionTask: @escaping () -> Void) {
        self.selectedTableCell = selectedTableCell
        self.completionTask = completionTask
    }
    
    private let duration: TimeInterval = 0.6
    private let transitionViewOverlapPercentage = 20.0
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    private func transitionView(from source: UIView, to destination: UIView, usingBaseView baseView: UIView, duration: TimeInterval, onCompletion completionHandler: (() -> Void)? = nil) {
        let sourceSize = source.sizeThatFits(CGSize.zero)
        let sourceSnapshot = source.snapshotView(afterScreenUpdates: false)!
        let frameOfSourceInBaseView = baseView.convert(source.frame, from: source.superview!)
        sourceSnapshot.frame = frameOfSourceInBaseView
        baseView.addSubview(sourceSnapshot)
        
        let destinationSize = destination.sizeThatFits(CGSize.zero)
        let destinationSnapshot = destination.snapshotView(afterScreenUpdates: true)!
        let frameOfDestinationInBaseView = baseView.convert(destination.frame, from: destination.superview!)
        destinationSnapshot.frame = frameOfDestinationInBaseView
        baseView.addSubview(destinationSnapshot)
        
        let sizeDifferenceScaleOnX = destinationSize.width/sourceSize.width
        let sizeDifferenceScaleOnY = destinationSize.height/sourceSize.height
        
        let transitionFinishLocationCenter = destinationSnapshot.center
        let sourceSizeTransformAtTransitionEnd = CGAffineTransform(scaleX: sizeDifferenceScaleOnX, y: sizeDifferenceScaleOnY)
        
        //Overlap destination on source before starting transition
        destinationSnapshot.alpha = 0
        destinationSnapshot.transform = CGAffineTransform(scaleX: 1/sizeDifferenceScaleOnX, y: 1/sizeDifferenceScaleOnY)
        destinationSnapshot.center = sourceSnapshot.center
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, options: .curveEaseIn, animations: {
            sourceSnapshot.center = transitionFinishLocationCenter
            sourceSnapshot.transform = sourceSizeTransformAtTransitionEnd
            destinationSnapshot.center = transitionFinishLocationCenter
            destinationSnapshot.transform = CGAffineTransform.identity
        }) { _ in
            if completionHandler != nil {
                completionHandler!()
            }
        }
        
        var fadeTransitionDuration = duration/2
        fadeTransitionDuration += (fadeTransitionDuration * transitionViewOverlapPercentage)/100
        let delay = duration - fadeTransitionDuration
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: fadeTransitionDuration, delay: 0, options: .curveEaseIn, animations: {
            sourceSnapshot.alpha = 0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: fadeTransitionDuration, delay: 0, options: .curveEaseIn, animations: {
                destinationSnapshot.alpha = 1
            })
        }
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let destinationVC = transitionContext.viewController(forKey: .to) as? RunningWorkoutViewController
        else {
            if let destinationView = transitionContext.viewController(forKey: .to)?.view {
                transitionContext.containerView.addSubview(destinationView)
            }
            transitionContext.completeTransition(true)
            return
        }
        
        guard let sourceVC = transitionContext.viewController(forKey: .from) as? ExerciseViewController
        else {
            if let destinationView = transitionContext.viewController(forKey: .to)?.view {
                transitionContext.containerView.addSubview(destinationView)
            }
            transitionContext.completeTransition(true)
            return
        }
                
        let animationDuration = duration * 0.8
        let transitionDuration = duration - animationDuration //Transition from final view created by transtion animation TO actual destination view.
        
        let destinationView = addDestinationViewToHierarchy(destinationVC: destinationVC, rootView: transitionContext.containerView)
        animationBaseView = createAnimationBaseView(toOverlap: destinationView, transitionContext: transitionContext)
        
        animateTransitionOfBackgroundColor(to: destinationView.backgroundColor, withBaseView: animationBaseView, withDuration: animationDuration)
        animateAppearanceOfExerciseCardView(presentInVC: destinationVC, withBaseView: animationBaseView, withDuration: animationDuration)
        
        transitionView(from: selectedTableCell.exerciseNameLabel, to: destinationVC.currentExerciseNameLabel, usingBaseView: animationBaseView, duration: animationDuration)
        transitionView(from: selectedTableCell.durationLabel, to: destinationVC.currentExerciseDurationLabel, usingBaseView: animationBaseView, duration: animationDuration)
        bringInView(sourceVC.exerciseControlsView, to: animationBaseView)
        
        let finalTransitionTask = createFinalTransitionTask(from: animationBaseView, to: destinationView, withDuration: transitionDuration, onCompletion: {transitionContext.completeTransition(true)})
        animateApperanceOfExerciseControls(presentInVC: destinationVC, withBaseView: animationBaseView, withDuration: animationDuration, onCompletion: finalTransitionTask)
    }
    
    func createFinalTransitionTask(from fromView: UIView, to toView: UIView, withDuration transitionDuration: Double, onCompletion completionHandler: (() -> Void)? = nil) -> () -> Void {
        return {UIView.transition(from: fromView, to: toView, duration: transitionDuration, options: [.showHideTransitionViews, .transitionCrossDissolve, .curveEaseOut], completion: { _ in
            if let completionHandler = completionHandler {
                completionHandler()
            }
        })
        }
    }
    
    func animateApperanceOfExerciseControls(presentInVC containingVC: RunningWorkoutViewController, withBaseView baseView: UIView, withDuration animationDuration: Double, onCompletion completionHandler: (() -> Void)? = nil) {
        let controlsViewSnapshot = containingVC.controlsContainerView.snapshotView(afterScreenUpdates: true)!
        let frameForControlsViewSnapshot = baseView.convert(containingVC.controlsContainerView.frame, from: containingVC.controlsContainerView.superview)
        controlsViewSnapshot.frame = frameForControlsViewSnapshot
        baseView.addSubview(controlsViewSnapshot)

        let existingAndAlsoFinalLocation = controlsViewSnapshot.center
        let distanceToDisplaceViewVerticallyDown = baseView.bounds.height - controlsViewSnapshot.frame.origin.y
        controlsViewSnapshot.center.y += distanceToDisplaceViewVerticallyDown
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animationDuration, delay: 0, options: .curveEaseIn, animations: {
            controlsViewSnapshot.center = existingAndAlsoFinalLocation
        }, completion: { _ in
            if let completionHandler = completionHandler {
                completionHandler()
            }
        })
    }
    
    @discardableResult
    func bringInView(_ viewToBringIn: UIView, to viewToBringInto: UIView) -> UIView {
        let viewSnapshot = viewToBringIn.snapshotView(afterScreenUpdates: false)!
        let viewFrame = viewToBringInto.convert(viewToBringIn.frame, from: viewToBringIn.superview!)
        viewSnapshot.frame = viewFrame
        viewToBringInto.addSubview(viewSnapshot)
        return viewSnapshot
    }
    
    func animateAppearanceOfExerciseCardView(presentInVC containingVC: RunningWorkoutViewController, withBaseView baseView: UIView, withDuration animationDuration: Double, onCompletion completionHandler: (() -> Void)? = nil) {
        let exerciseCardViewFrame = baseView.convert(containingVC.currentExerciseView.frame, from: containingVC.currentExerciseView.superview!)
        let exerciseContainerView = UIView(frame: exerciseCardViewFrame)
        exerciseContainerView.backgroundColor = containingVC.currentExerciseView.backgroundColor
        exerciseContainerView.alpha = 0.5
        exerciseContainerView.layer.cornerRadius = containingVC.currentExerciseView.layer.cornerRadius
        let existingCenter = exerciseContainerView.center
        
        //Displace it to the right of the screen
        exerciseContainerView.center = CGPoint(x: exerciseContainerView.center.x + exerciseContainerView.frame.width + (exerciseContainerView.frame.origin.x * 2), y: exerciseContainerView.center.y)
        baseView.addSubview(exerciseContainerView)
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animationDuration, delay: 0, options: .curveEaseIn, animations: {
            exerciseContainerView.alpha = 0.8
            exerciseContainerView.center = existingCenter
        }, completion: { _ in
            if let completionHandler = completionHandler {
                completionHandler()
            }
        })
    }
    
    func animateTransitionOfBackgroundColor(to destinationBackgroundColor: UIColor?, withBaseView baseView: UIView, withDuration animationDuration: Double, onCompletion completionHandler: (() -> Void)? = nil) {
        let backgroundColorView = UIView(frame: baseView.bounds)
        backgroundColorView.backgroundColor = destinationBackgroundColor
        backgroundColorView.alpha = 0
        baseView.addSubview(backgroundColorView)
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animationDuration, delay: 0, options: .curveEaseIn, animations: {
            backgroundColorView.alpha = 0.8
        }, completion: { _ in
            if let completionHandler = completionHandler {
                completionHandler()
            }
        })
    }
    
    func addDestinationViewToHierarchy(destinationVC: UIViewController, rootView: UIView) -> UIView {
        let destinationView = destinationVC.view!
        rootView.addSubview(destinationView)
        destinationView.layoutIfNeeded()
        return destinationView
    }
    
    func createAnimationBaseView(toOverlap referenceView: UIView, transitionContext: UIViewControllerContextTransitioning) -> UIView {
        let baseView = UIView(frame: referenceView.frame)
        baseView.backgroundColor = transitionContext.viewController(forKey: .from)?.view.backgroundColor
        transitionContext.containerView.addSubview(baseView)
        return baseView
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        animationBaseView?.removeFromSuperview()
        completionTask()
    }
}
