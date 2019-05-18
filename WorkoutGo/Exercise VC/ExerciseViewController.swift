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

class ExerciseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ExerciseTableViewCellDelegate, UINavigationControllerDelegate {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItems?.append(self.editButtonItem)
        exercises = try! Exercise.getAllExerciseInfo(forWorkoutProgram: workoutProgram, forWorkout: workout)
        tableView.reloadData()
        navigationController?.delegate = self
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
        if segue.identifier == "Start Workout" {
            if let runningWorkoutVC = segue.destination as? RunningWorkoutViewController {
                runningWorkoutVC.exerciseInfo = (tableView.cellForRow(at: tableView.indexPathForSelectedRow ?? IndexPath(row: 0, section: 0)) as! ExerciseTableViewCell).exerciseInfo
            }
        }
    }
    
    // MARK: - View controller transition animation handling
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            return StartWorkoutTransitionAnimator(exerciseCell: tableView.cellForRow(at: tableView.indexPathForSelectedRow ?? IndexPath(row: 0, section: 0)) as! ExerciseTableViewCell)
        }
        
        return nil
    }
}

class StartWorkoutTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private var exerciseCell: ExerciseTableViewCell
    private var maskingView: UIView!
    
    init(exerciseCell: ExerciseTableViewCell) {
        self.exerciseCell = exerciseCell
    }
    
    private let duration: TimeInterval = 0.35
    private let transitionViewOverlapPercentage = 20.0
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    private func transitionView(from source: UIView, to destination: UIView, usingBaseViewForTransition baseView: UIView, onCompletion completionHandler: (() -> Void)? = nil) {
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
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let destinationView = transitionContext.view(forKey: .to)
        transitionContext.containerView.addSubview(destinationView!)
        destinationView?.layoutIfNeeded()
        
        let destinationVC = transitionContext.viewController(forKey: .to) as! RunningWorkoutViewController
        let destinationViewFrame = transitionContext.finalFrame(for: destinationVC)
        
        maskingView = UIView(frame: destinationViewFrame)
        maskingView.backgroundColor = .white
        transitionContext.containerView.addSubview(self.maskingView)
        
        transitionView(from: exerciseCell.exerciseNameTextField, to: destinationVC.exerciseNameLabel, usingBaseViewForTransition: maskingView)
        transitionView(from: exerciseCell.durationLabel, to: destinationVC.exerciseDurationLabel, usingBaseViewForTransition: maskingView)  {
            transitionContext.completeTransition(true)
        }
        
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
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, options: .curveEaseIn, animations: {
            destinationControlsView.center = destinationControlsViewFinalCenter
        })
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        maskingView.removeFromSuperview()
    }
}
