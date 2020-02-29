//
//  WorkoutTableViewController.swift
//  WorkoutGo
//
//  Created by Ashish Bansal on 24/04/19.
//  Copyright © 2019 Ashish Bansal. All rights reserved.
//

import UIKit

class WorkoutTableViewController: UITableViewController, Add_Edit_WorkoutExerciseDelegate {
    
    var workoutNameSendAction: ((String) -> Void)?
    let exerciseInfoSendAction: ((ExerciseInfo) -> Void)? = nil //Not used. Only for protocol conformance
    
    func canAcceptName(_ name: String) -> (answer: Bool, errorMessage: String) {
        if workouts.contains(name) {
            return (answer: false, errorMessage: "Workout with this name already exists.")
        }
        
        return (answer: true, errorMessage: "")
    }

    var workoutProgramName = "Workouts"
    private var workouts = [String]()
    {
        didSet {
            if workouts.isEmpty {
                comeOutOfEditingMode()
                displayTableBackgroundForNoData()
                editButtonItem.isEnabled = false
            }
            else {
                removeTableBackground()
                editButtonItem.isEnabled = true
            }
        }
    }
    
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
        navigationController?.navigationBar.prefersLargeTitles = true
        title = workoutProgramName
        navigationItem.rightBarButtonItems?.append(self.editButtonItem)
        createWorkoutProgramIfNotAvailable(withName: workoutProgramName)
        addSampleWorkouts(toWorkoutProgram: workoutProgramName)
        workouts = try! Workout.getAllWorkoutNames(forWorkoutProgram: workoutProgramName)
        if workouts.isEmpty {
            displayTableBackgroundForNoData()
        }
    }
    
    private func addSampleWorkouts(toWorkoutProgram programName: String) {
        guard let sampleWorkouts = SampleWorkout.loadFrom(jsonFile: "SampleWorkouts.json")
            else {
                return
            }
        for (workoutIndex, workout) in sampleWorkouts.enumerated() {
            try? Workout.addWorkout(forProgram: programName, withName: workout.name, rowNum: workoutIndex)
            
            for (exerciseIndex, exercise) in workout.exercises.enumerated() {
                try? Exercise.addExercise(forWorkoutProgram: programName, forWorkout: workout.name, withName: exercise.name, withDuration: exercise.duration, rowNum: exerciseIndex)
            }
        }
    }
    
    private func createWorkoutProgramIfNotAvailable(withName workoutProgramName: String) {
        let workoutProgram = try? WorkoutProgram.getWorkoutProgram(forName: workoutProgramName)
        if workoutProgram == nil {
            WorkoutProgram.addWorkoutProgram(withName: workoutProgramName, rowNum: 0)
        }
    }
    
    private func displayTableBackgroundForNoData() {
            tableView.backgroundView = {
                let emptyTableLabel = UILabel()
                emptyTableLabel.numberOfLines = 0
                emptyTableLabel.text = "Add workouts to continue"
                emptyTableLabel.textColor = .systemGray
                emptyTableLabel.font = UIFont.preferredFont(forTextStyle: .title3)
                emptyTableLabel.textAlignment = .center
                return emptyTableLabel
            }()
            
            tableView.separatorStyle = .none
    }
    
    private func removeTableBackground() {
        if tableView.backgroundView != nil
        {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
    }

    // MARK: - Data source methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Workout Cell", for: indexPath)
        if let workoutCell = cell as? WorkoutTableViewCell {
            workoutCell.name = workouts[indexPath.row]
        }

        return cell
    }

    // MARK: - Addition of data
    
    private func addWorkout(_ name: String) {
        workouts.append(name)
        let indexOfNewWorkout = workouts.firstIndex(of: name)
        try! Workout.addWorkout(forProgram: workoutProgramName, withName: name, rowNum: indexOfNewWorkout!)
        tableView.insertRows(at: [IndexPath(row: indexOfNewWorkout!, section: 0)], with: .automatic)
    }
    
    @IBAction func addWorkoutButton(_ sender: UIBarButtonItem) {
        workoutNameSendAction = {name in
            self.addWorkout(name)
        }
        performSegue(withIdentifier: "Add_Edit Workout", sender: sender)
    }
    
    
    // MARK: - Editing of table
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isEditing
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            workouts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        if editing == false, isEditing == true //This means that editing went from true to false i.e. editing ended
        {
            try! Workout.synchronize(withData: workouts, forProgram: workoutProgramName)
        }
        super.setEditing(editing, animated: animated)
        
        if isEditing {
            addButton?.isEnabled = false
        }
        else {
            addButton?.isEnabled = true
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedWorkout = workouts.remove(at: fromIndexPath.row)
        workouts.insert(movedWorkout, at: to.row)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        workoutNameSendAction = {name in
            self.updateWorkoutName(at: indexPath, to: name)
        }
        performSegue(withIdentifier: "Add_Edit Workout", sender: indexPath)
    }
    
    // MARK: - Renaming of data
    
    func updateWorkoutName(at indexPath: IndexPath, to newName: String) {
        let oldName = workouts[indexPath.row]
        workouts[indexPath.row] = newName
        tableView.reloadRows(at: [indexPath], with: .automatic)
        try! Workout.updateWorkoutName(forProgram: workoutProgramName, from: oldName, to: newName)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "Open Workout":
            if let exerciseVC = segue.destination as? ExerciseViewController, let selectedCell = sender as? WorkoutTableViewCell {
                exerciseVC.workoutProgram = workoutProgramName
                exerciseVC.workout = selectedCell.name
            }
            
        case "Add_Edit Workout":
            if let addEditWorkoutVC = segue.destination as? Add_Edit_WorkoutExercise_ViewController {
                addEditWorkoutVC.delegate = self
                addEditWorkoutVC.operationType = .workout
                
                switch sender {
                case is UIBarButtonItem:
                    addEditWorkoutVC.title = "Add Workout"
                    
                case let indexPath as IndexPath:
                    addEditWorkoutVC.title = "Edit Workout"
                    addEditWorkoutVC.previousWorkoutName = workouts[indexPath.row]
                    
                default:
                    break
                }
            }
            
        default:
            break
        }
    }
}
