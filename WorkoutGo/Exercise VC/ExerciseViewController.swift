//
//  ExerciseViewController.swift
//  WorkoutGo
//
//  Created by Ashish Bansal on 25/04/19.
//  Copyright © 2019 Ashish Bansal. All rights reserved.
//

import UIKit

struct ExerciseInfo: Equatable {
    var name: String
    var duration: Int
}

extension DateComponentsFormatter {
    static let common: DateComponentsFormatter = {
        var dateComponentFormatter = DateComponentsFormatter()
        dateComponentFormatter.allowedUnits = [.minute, .second]
        dateComponentFormatter.zeroFormattingBehavior = .pad
        return dateComponentFormatter
    }()
}

// MARK: -
// MARK: -

class ExerciseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ExerciseTableViewCellDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    @IBOutlet weak var exerciseControlsView: UIView!
    
    // MARK: -
    
    var workoutProgram: String!
    var workout: String!
    private var exercises = [ExerciseInfo]()
    var existingDelegate: UINavigationControllerDelegate?
    var existingGestureRecognizerDelegate: UIGestureRecognizerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItems?.append(self.editButtonItem)
        exercises = try! Exercise.getAllExerciseInfo(forWorkoutProgram: workoutProgram, forWorkout: workout)
        tableView.reloadData()
        
        existingGestureRecognizerDelegate = navigationController?.interactivePopGestureRecognizer?.delegate
        print("Interactive pop gesture recogizer delegate present \(existingGestureRecognizerDelegate != nil). Interactive pop gesture enabled \(navigationController?.interactivePopGestureRecognizer?.isEnabled)")
        if existingGestureRecognizerDelegate != nil {
            print("Interactive pop gesture recogizer delegate ID \(ObjectIdentifier(existingGestureRecognizerDelegate!))")
            //navigationController?.interactivePopGestureRecognizer?.delegate = self
        }
        existingDelegate = navigationController?.delegate
        //navigationController?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.addTarget(self, action: #selector(popTriggered(recognizer:)))
    }
    
    @objc func popTriggered(recognizer: UIGestureRecognizer) {
        //print("Pop triggered. State \(recognizer.state)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("Exercise VC viewWillDisappear")
        super.viewWillDisappear(animated)
        //navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("Exercise VC viewDidDisappear")
        super.viewDidDisappear(animated)
        //navigationController?.delegate = existingDelegate
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let captureValue = existingGestureRecognizerDelegate?.gestureRecognizerShouldBegin?(gestureRecognizer)
        print("GestureRecognizerDelegate - gestureRecognizerShouldBegin \(captureValue)")
        return captureValue ?? true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
        let captureValue = existingGestureRecognizerDelegate?.gestureRecognizer?(gestureRecognizer, shouldReceive: press)
        print("GestureRecognizerDelegate - shouldReceive - press \(captureValue)")
        return captureValue ?? true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let captureValue = existingGestureRecognizerDelegate?.gestureRecognizer?(gestureRecognizer, shouldReceive: touch)
        print("GestureRecognizerDelegate - shouldReceive - touch \(captureValue)")
        return captureValue ?? true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let captureValue = existingGestureRecognizerDelegate?.gestureRecognizer?(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer)
        print("GestureRecognizerDelegate - shouldRecognizeSimultaneouslyWith \(captureValue)")
        return captureValue ?? false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let captureValue = existingGestureRecognizerDelegate?.gestureRecognizer?(gestureRecognizer, shouldRequireFailureOf: otherGestureRecognizer)
        print("GestureRecognizerDelegate - shouldRequireFailureOf \(captureValue)")
        return captureValue ?? false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let captureValue = existingGestureRecognizerDelegate?.gestureRecognizer?(gestureRecognizer, shouldBeRequiredToFailBy: otherGestureRecognizer)
        print("GestureRecognizerDelegate - shouldBeRequiredToFailBy \(captureValue)")
        return captureValue ?? false
    }
    
    // MARK: - Data source methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Exercise Cell", for: indexPath)
        if let exerciseCell = cell as? ExerciseTableViewCell {
            exerciseCell.exerciseInfo = exercises[indexPath.row]
            exerciseCell.delegate = self
        }
        
        return cell
    }
    
    // MARK: - Addition of data
    
    @IBAction func addWorkout(_ sender: UIBarButtonItem) {
        let existingExerciseNames = exercises.map { $0.name }
        let newExerciseName = "Untitled".madeUnique(withRespectTo: existingExerciseNames)
        let newExercise = ExerciseInfo(name: newExerciseName, duration: 30)
        exercises.append(newExercise)
        let indexOfNewExercise = exercises.firstIndex(of: newExercise)
        try! Exercise.addExercise(forWorkoutProgram: workoutProgram, forWorkout: workout, withName: newExercise.name, rowNum: indexOfNewExercise!)
        tableView.insertRows(at: [IndexPath(row: indexOfNewExercise!, section: 0)], with: .automatic)
    }
    
    // MARK: - Editing of table
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView.isEditing
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            exercises.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        if editing == false, isEditing == true //This means that editing went from true to false i.e. editing ended
        {
            try! Exercise.synchronize(withData: exercises, forProgram: workoutProgram, forWorkout: workout)
        }
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedExercise = exercises.remove(at: sourceIndexPath.row)
        exercises.insert(movedExercise, at: destinationIndexPath.row)
    }
    
    // MARK: - Renaming of data
    
    func didUpdateExerciseName(from oldName: String, to newName: String, inCell cell: ExerciseTableViewCell) {
        let existingExerciseNames = exercises.map { $0.name }
        if existingExerciseNames.contains(newName) == false {
            let indexPath = tableView.indexPath(for: cell)
            exercises[indexPath!.row].name = newName
            try! Exercise.updateExercise(forProgram: workoutProgram, forWorkout: workout, from: oldName, to: newName, withDuration: cell.exerciseInfo.duration)
        }
        else {
            cell.exerciseInfo.name = oldName
            alertUserForPreexistingName(whenUpdatingCell: cell)
        }
    }
    
    private func alertUserForPreexistingName(whenUpdatingCell cell: ExerciseTableViewCell) {
        let alert = UIAlertController(title: "Name already exists", message: "Another exercise already exists with this name. Enter a different name", preferredStyle: .alert)
        let alertAction_OK = UIAlertAction(title: "Ok", style: .default) { _ in
            cell.receiveNameFromUser()
        }
        alert.addAction(alertAction_OK)
        present(alert, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Exercise VC - prepare for segue called")
        if segue.identifier == "Start Workout" {
            if let runningWorkoutVC = segue.destination as? RunningWorkoutViewController {
                runningWorkoutVC.exerciseInfo = (tableView.cellForRow(at: tableView.indexPathForSelectedRow ?? IndexPath(row: 0, section: 0)) as! ExerciseTableViewCell).exerciseInfo
            }
        }
    }
    
    
    @IBAction func startWorkout(_ sender: UIButton) {
        navigationController?.delegate = self
        performSegue(withIdentifier: "Start Workout", sender: sender)
    }
    
    // MARK: - View controller transition animation handling
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("Exercise VC - Controller animator requested for operation \(operation.rawValue)")
        if operation == .push {
            return StartWorkoutTransitionAnimator(exerciseCell: tableView.cellForRow(at: tableView.indexPathForSelectedRow ?? IndexPath(row: 0, section: 0)) as! ExerciseTableViewCell, completionTask: {
                navigationController.delegate = self.existingDelegate
                print("Restored the navigation controller delegate")
            })
        }
        
        //return existingDelegate?.navigationController?(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
        return nil
    }
    
//    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//        existingDelegate?.navigationController?(navigationController, didShow: viewController, animated: animated)
//    }
//
//    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//        existingDelegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
//    }
//
//    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        return existingDelegate?.navigationController?(navigationController, interactionControllerFor: animationController)
//    }
    
//    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
//        return existingDelegate!.navigationControllerSupportedInterfaceOrientations!(navigationController)
//    }
//
//    func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
//        return existingDelegate!.navigationControllerPreferredInterfaceOrientationForPresentation!(navigationController)
//    }
}

class StartWorkoutTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private var exerciseCell: ExerciseTableViewCell
    private var maskingView: UIView!
    private let completionTask: () -> Void
    
    init(exerciseCell: ExerciseTableViewCell, completionTask: @escaping () -> Void) {
        self.exerciseCell = exerciseCell
        self.completionTask = completionTask
    }
    
    deinit {
        print("VC Transition animator thrown out of the heap")
    }
    
    private let duration: TimeInterval = 0.6
    private let transitionViewOverlapPercentage = 20.0
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        print("Running VC - Controller animator - transition duration requested")
        return duration
    }
    
    private func transitionView(from source: UIView, to destination: UIView, usingBaseViewForTransition baseView: UIView, duration: TimeInterval, onCompletion completionHandler: (() -> Void)? = nil) {
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
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: fadeTransitionDuration, delay: 0, options: .curveEaseIn, animations: {
            sourceSnapshot.alpha = 0
        })
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: fadeTransitionDuration, delay: duration - fadeTransitionDuration, options: .curveEaseIn, animations: {
            destinationSnapshot.alpha = 1
        })
    }
    
    let polygonColor = UIColor(patternImage: UIImage(named: "BlackPolygon")!)
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        print("Running VC - Controller animator - transition animation start requested")
        
        let animationDuration = duration * 0.8
        let transitionDuration = duration - animationDuration
        
        let destinationView = transitionContext.view(forKey: .to)
        transitionContext.containerView.addSubview(destinationView!)
        destinationView?.layoutIfNeeded()
        
        let destinationVC = transitionContext.viewController(forKey: .to) as! RunningWorkoutViewController
        let destinationViewFrame = transitionContext.finalFrame(for: destinationVC)
        
        maskingView = UIView(frame: destinationViewFrame)
        maskingView.backgroundColor = .white
        transitionContext.containerView.addSubview(self.maskingView)
        
        let maskingViewBackgroundColorView = UIView(frame: maskingView.bounds)
        maskingViewBackgroundColorView.backgroundColor = destinationView?.backgroundColor
        maskingViewBackgroundColorView.alpha = 0
        maskingView.addSubview(maskingViewBackgroundColorView)
        
        var exerciseCardViewFrame = maskingView.convert(destinationVC.currentExerciseView.frame, from: destinationVC.currentExerciseView.superview!)
        exerciseCardViewFrame.origin.x = (maskingView.bounds.width - exerciseCardViewFrame.width)/2
        let exerciseContainerView = UIView(frame: exerciseCardViewFrame)
        exerciseContainerView.backgroundColor = destinationVC.currentExerciseView.backgroundColor
        exerciseContainerView.alpha = 0.5
        exerciseContainerView.layer.cornerRadius = destinationVC.currentExerciseView.layer.cornerRadius
        maskingView.addSubview(exerciseContainerView)
        
        let existingCenter = exerciseContainerView.center
        exerciseContainerView.center = CGPoint(x: exerciseContainerView.center.x + exerciseContainerView.frame.width + (exerciseContainerView.frame.origin.x * 2), y: exerciseContainerView.center.y)
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animationDuration, delay: 0, options: .curveEaseIn, animations: {
            exerciseContainerView.alpha = 0.8
            exerciseContainerView.center = existingCenter
        })
        
        transitionView(from: exerciseCell.exerciseNameTextField, to: destinationVC.exerciseNameLabel, usingBaseViewForTransition: maskingView, duration: animationDuration)
        transitionView(from: exerciseCell.durationLabel, to: destinationVC.exerciseDurationLabel, usingBaseViewForTransition: maskingView, duration: animationDuration)
        
        let sourceVC = transitionContext.viewController(forKey: .from) as! ExerciseViewController
        let sourceControlsViewSnapshot = sourceVC.exerciseControlsView.snapshotView(afterScreenUpdates: false)!
        let sourceControlViewFrameInMaskingView = maskingView.convert(sourceVC.exerciseControlsView.frame, from: sourceVC.exerciseControlsView.superview!)
        sourceControlsViewSnapshot.frame = sourceControlViewFrameInMaskingView
        maskingView.addSubview(sourceControlsViewSnapshot)        
        
        let destinationControlsView = destinationVC.controlsContainerView.snapshotView(afterScreenUpdates: true)!
        let destinationControlViewFrameInMaskingView = maskingView.convert(destinationVC.controlsContainerView.frame, from: destinationVC.controlsContainerView.superview)
        destinationControlsView.frame = destinationControlViewFrameInMaskingView
        maskingView.addSubview(destinationControlsView)
        
        let distanceToMoveDestinationControlView = maskingView.bounds.height - destinationControlsView.frame.origin.y
        let destinationControlsViewFinalCenter = destinationControlsView.center
        destinationControlsView.center.y += distanceToMoveDestinationControlView
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animationDuration, delay: 0, options: .curveEaseIn, animations: {
            destinationControlsView.center = destinationControlsViewFinalCenter
        }, completion: { _ in
            UIView.transition(from: self.maskingView, to: destinationView!, duration: transitionDuration, options: [.showHideTransitionViews, .transitionCrossDissolve, .curveEaseOut], completion: { _ in
                transitionContext.completeTransition(true)
            })
        })
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animationDuration, delay: 0, options: .curveEaseIn, animations: {
            maskingViewBackgroundColorView.alpha = 0.8
        })
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        print("Running VC - Controller animator - transition end notified")
        maskingView.removeFromSuperview()
        completionTask()
    }
}
