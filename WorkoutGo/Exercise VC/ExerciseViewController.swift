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

// MARK: -
// MARK: -

class ExerciseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, Add_Edit_WorkoutExerciseDelegate
{
    let workoutNameSendAction: ((String) -> Void)? = nil
    var exerciseInfoSendAction: ((ExerciseInfo) -> Void)?
    
    func canAcceptName(_ name: String) -> (answer: Bool, errorMessage: String) {
        return (true, "")
    }
    
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
    {
        didSet {
            if exercises.isEmpty {
                comeOutOfEditingMode()
                updateTableForNoExercises()
                editButtonItem.isEnabled = false
            }
            else {
                removeTableUpdatesForNoExercises()
                editButtonItem.isEnabled = true
            }
        }
    }
    var existingDelegate: UINavigationControllerDelegate?
    var startingPositionIndicatorRowNum = 0
    
    private func comeOutOfEditingMode() {
        if isEditing {
            DispatchQueue.main.async {
                let _ = self.editButtonItem.target?.perform(self.editButtonItem.action)
            }
        }
    }
    
    var addButton: UIBarButtonItem? {
        navigationItem.rightBarButtonItems?.first
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Status bar navigation style: \(preferredStatusBarStyle.rawValue). Navcontroller's \(navigationController?.preferredStatusBarStyle.rawValue)")
        title = workout
        navigationItem.rightBarButtonItems?.append(self.editButtonItem)
        exercises = try! Exercise.getAllExerciseInfo(forWorkoutProgram: workoutProgram, forWorkout: workout)
        tableView.reloadData()
        if exercises.isEmpty {
            updateTableForNoExercises()
        }
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func updateTableForNoExercises() {
            tableView.backgroundView = {
                let emptyTableLabel = UILabel()
                emptyTableLabel.numberOfLines = 0
                emptyTableLabel.text = "Add exercises to continue"
                emptyTableLabel.textColor = .systemGray
                emptyTableLabel.font = UIFont.preferredFont(forTextStyle: .title3)
                emptyTableLabel.textAlignment = .center
                return emptyTableLabel
            }()
            
            tableView.separatorStyle = .none
    }
    
    private func removeTableUpdatesForNoExercises() {
        if tableView.backgroundView != nil
        {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
    }
    
    // MARK: - Data source methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if exercises.isEmpty {
            return 0
        }
        
        return startingPositionIndicatorRowNum == -1 ? exercises.count : exercises.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if  indexPath.row == startingPositionIndicatorRowNum {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Starting Position Indicator Cell", for: indexPath)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Exercise Cell", for: indexPath)
        if let exerciseCell = cell as? ExerciseTableViewCell {
            let exerciseRowNum = startingPositionIndicatorRowNum == -1 || indexPath.row < startingPositionIndicatorRowNum ? indexPath.row : indexPath.row - 1
            exerciseCell.exerciseInfo = exercises[exerciseRowNum]
        }
        
        return cell
    }
    
    // MARK: - Addition of data
    
    private func addExercise(withInfo newExercise: ExerciseInfo) {
        exercises.append(newExercise)
        let indexOfNewExercise = exercises.firstIndex(of: newExercise)
        try! Exercise.addExercise(forWorkoutProgram: workoutProgram, forWorkout: workout, withName: newExercise.name, rowNum: indexOfNewExercise!)
        
        var indexPathsOfRowsToBeInserted = [IndexPath]()
        
        if indexOfNewExercise == 0 { // i.e. this is the first exercise to be inserted
            let indexPathOfStartPositionIndicatorRow = IndexPath(row: startingPositionIndicatorRowNum, section: 0)
            indexPathsOfRowsToBeInserted.append(indexPathOfStartPositionIndicatorRow)
        }
        
        let indexPathOfExerciseRow = IndexPath(row: indexOfNewExercise! + 1, section: 0)
        indexPathsOfRowsToBeInserted.append(indexPathOfExerciseRow)
        
        tableView.insertRows(at: indexPathsOfRowsToBeInserted, with: .automatic)
    }
    
    @IBAction func addWorkout(_ sender: UIBarButtonItem) {
        exerciseInfoSendAction = {(exerciseInfo) in
            self.addExercise(withInfo: exerciseInfo)
        }
        performSegue(withIdentifier: "Add_Edit Exercise", sender: sender)
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
        
        if editing == true {
            let existingStartingPositionIndicatorRowNum = startingPositionIndicatorRowNum
            startingPositionIndicatorRowNum = -1
            tableView.deleteRows(at: [IndexPath(row: existingStartingPositionIndicatorRowNum, section: 0)], with: .automatic)
        }
        else {
            startingPositionIndicatorRowNum = 0
            if exercises.isEmpty == false {
                tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
        }
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
        
        if isEditing {
            addButton?.isEnabled = false
        }
        else {
            addButton?.isEnabled = true
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedExercise = exercises.remove(at: sourceIndexPath.row)
        exercises.insert(movedExercise, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        try! Exercise.synchronize(withData: exercises, forProgram: workoutProgram, forWorkout: workout)
        exerciseInfoSendAction = {(exerciseInfo) in
            self.updateExerciseDetails(at: indexPath, to: exerciseInfo)
        }
        performSegue(withIdentifier: "Add_Edit Exercise", sender: indexPath)
    }
    
    // MARK: - Update of data
    func updateExerciseDetails(at indexPath: IndexPath, to newExercise: ExerciseInfo) {
        exercises[indexPath.row] = newExercise
        tableView.reloadRows(at: [indexPath], with: .automatic)
        try! Exercise.updateExercise(forProgram: workoutProgram, forWorkout: workout, at: indexPath.row, to: newExercise.name, withDuration: newExercise.duration)
    }

    @IBAction func startWorkout(_ sender: UIButton) {
        existingDelegate = navigationController?.delegate
        navigationController?.delegate = self
        performSegue(withIdentifier: "Start Workout", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "Start Workout":
            if let runningWorkoutVC = segue.destination as? RunningWorkoutViewController {
                runningWorkoutVC.exerciseInfoList = exercises
                runningWorkoutVC.currentExerciseInfoIndex = startingPositionIndicatorRowNum
            }
            
        case "Add_Edit Exercise":
            if let addEditExerciseVC = segue.destination as? Add_Edit_WorkoutExercise_ViewController {
                addEditExerciseVC.delegate = self
                addEditExerciseVC.operationType = .exercise
                
                switch sender {
                case is UIBarButtonItem:
                    addEditExerciseVC.title = "Add Exercise"
                    
                case let indexPath as IndexPath:
                    addEditExerciseVC.title = "Edit Exercise"
                    addEditExerciseVC.previousExerciseInfo = exercises[indexPath.row]
                    
                default:
                    break
                }
            }
            
        default:
            break
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) is ExerciseTableViewCell {
            let currentStartingPositionRowIndexPath = IndexPath(row: startingPositionIndicatorRowNum, section: 0)
            let targetStartingPositionRowIndexPath = IndexPath(row: indexPath.row < startingPositionIndicatorRowNum ? indexPath.row : indexPath.row - 1, section: 0)
            
            if tableView.cellForRow(at: currentStartingPositionRowIndexPath) != nil {
                startingPositionIndicatorRowNum = targetStartingPositionRowIndexPath.row
                tableView.moveRow(at: currentStartingPositionRowIndexPath, to: targetStartingPositionRowIndexPath)
            }
            else {
                tableView.performBatchUpdates({
                    startingPositionIndicatorRowNum = -1
                    tableView.deleteRows(at: [currentStartingPositionRowIndexPath], with: .automatic)
                    startingPositionIndicatorRowNum = targetStartingPositionRowIndexPath.row
                    tableView.insertRows(at: [targetStartingPositionRowIndexPath], with: .automatic)
                })
            }
        }
    }
    
    var getCurrentSelectedCell: ExerciseTableViewCell {
        return tableView.cellForRow(at: IndexPath(row: startingPositionIndicatorRowNum + 1, section: 0)) as! ExerciseTableViewCell
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
