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

// TODO: Move to where used OR create separate file
func Globalfunc_durationFormatter(seconds: Int) -> String {
    let secondsComponent = seconds % 60
    let minutes = seconds / 60
    
    var formattedTimeDuration = ""
    if minutes < 10 {
        formattedTimeDuration.append("0")
    }
    formattedTimeDuration.append("\(minutes):")
    
    if secondsComponent < 10 {
        formattedTimeDuration.append("0")
    }
    formattedTimeDuration.append("\(secondsComponent)")
    return formattedTimeDuration
}

// MARK: -
// MARK: -

class ExerciseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ExerciseTableViewCellDelegate, UINavigationControllerDelegate
{    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItems?.append(self.editButtonItem)
        exercises = try! Exercise.getAllExerciseInfo(forWorkoutProgram: workoutProgram, forWorkout: workout)
        tableView.reloadData()
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

    @IBAction func startWorkout(_ sender: UIButton) {
        existingDelegate = navigationController?.delegate
        navigationController?.delegate = self
        performSegue(withIdentifier: "Start Workout", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Start Workout" {
            if let runningWorkoutVC = segue.destination as? RunningWorkoutViewController {
                runningWorkoutVC.exerciseInfoList = exercises
                runningWorkoutVC.currentExerciseInfoIndex = tableView.indexPath(for: getCurrentSelectedCell)!.row
            }
        }
    }
    
    // MARK: - View controller transition animation handling
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            return StartWorkoutTransitionAnimator(selectedTableCell: getCurrentSelectedCell, completionTask: {
                navigationController.delegate = self.existingDelegate
            })
        }
        
        return nil
    }
    
    var getCurrentSelectedCell: ExerciseTableViewCell {
        return tableView.cellForRow(at: tableView.indexPathForSelectedRow ?? IndexPath(row: 0, section: 0)) as! ExerciseTableViewCell
    }
}

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

//        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: fadeTransitionDuration, delay: duration - fadeTransitionDuration, options: .curveEaseIn, animations: {
//            destinationSnapshot.alpha = 1
//        })
        
        Timer.scheduledTimer(withTimeInterval: 0, repeats: false) { _ in
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: fadeTransitionDuration, delay: delay, options: .curveEaseIn, animations: {
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
        
        transitionView(from: selectedTableCell.exerciseNameTextField, to: destinationVC.currentExerciseNameLabel, usingBaseView: animationBaseView, duration: animationDuration)
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
