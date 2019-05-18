//
//  WorkoutTableViewController.swift
//  WorkoutGo
//
//  Created by Ashish Bansal on 24/04/19.
//  Copyright © 2019 Ashish Bansal. All rights reserved.
//

import UIKit

class WorkoutTableViewController: UITableViewController, WorkoutTableViewCellDelegate {

    var workoutProgram: String!
    private var workouts = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = workoutProgram
        self.navigationItem.rightBarButtonItems?.append(self.editButtonItem)
        workouts = try! Workout.getAllWorkoutNames(forWorkoutProgram: workoutProgram)
    }

    // MARK: - Data source methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Workout Cell", for: indexPath)
        if let workoutCell = cell as? WorkoutTableViewCell {
            workoutCell.name = workouts[indexPath.row]
            workoutCell.delegate = self
        }

        return cell
    }

    // MARK: - Addition of data
    
    @IBAction func addWorkout(_ sender: UIBarButtonItem) {
        let newWorkout = "Untitled".madeUnique(withRespectTo: workouts)
        workouts.append(newWorkout)
        let indexOfNewWorkout = workouts.firstIndex(of: newWorkout)
        try! Workout.addWorkout(forProgram: workoutProgram, withName: newWorkout, rowNum: indexOfNewWorkout!)
        tableView.insertRows(at: [IndexPath(row: indexOfNewWorkout!, section: 0)], with: .automatic)
    }
    
    // MARK: - Editing of table
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView.isEditing
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
            try! Workout.synchronize(withData: workouts, forProgram: workoutProgram)
        }
        super.setEditing(editing, animated: animated)
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedWorkout = workouts.remove(at: fromIndexPath.row)
        workouts.insert(movedWorkout, at: to.row)
    }
    
    // MARK: - Renaming of data
    
    func didUpdateWorkoutName(from oldName: String, to newName: String, inCell cell: WorkoutTableViewCell) {
        if workouts.contains(newName) == false {
            let indexPath = tableView.indexPath(for: cell)
            workouts[indexPath!.row] = newName
            try! Workout.updateWorkoutName(forProgram: workoutProgram, from: oldName, to: newName)
        }
        else {
            cell.name = oldName
            alertUserForPreexistingName(whenUpdatingCell: cell)
        }
    }
    
    private func alertUserForPreexistingName(whenUpdatingCell cell: WorkoutTableViewCell) {
        let alert = UIAlertController(title: "Name already exists", message: "Another workout already exists with this name. Enter a different name", preferredStyle: .alert)
        let alertAction_OK = UIAlertAction(title: "Ok", style: .default) { _ in
            cell.receiveNameFromUser()
        }
        alert.addAction(alertAction_OK)
        present(alert, animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Open Workout" {
            if let exerciseVC = segue.destination as? ExerciseViewController, let selectedCell = sender as? WorkoutTableViewCell {
                exerciseVC.workoutProgram = workoutProgram
                exerciseVC.workout = selectedCell.workoutNameTextField.text
            }
        }
    }
}
