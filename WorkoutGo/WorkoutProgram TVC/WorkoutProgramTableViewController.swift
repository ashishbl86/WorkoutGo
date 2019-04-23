//
//  WorkoutProgramTableViewController.swift
//  WorkoutGo
//
//  Created by Ashish Bansal on 21/04/19.
//  Copyright © 2019 Ashish Bansal. All rights reserved.
//

import UIKit

class WorkoutProgramTableViewController: UITableViewController, WorkoutProgramTableViewCellDelegate {
    
    @IBAction func reloadData(_ sender: UIBarButtonItem) {
        workoutPrograms = try! WorkoutProgram.getAllWorkoutProgramNames()
        tableView.reloadData()
    }
    
    private var workoutPrograms = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Workout Programs"
        self.navigationItem.rightBarButtonItems?.append(self.editButtonItem)
        workoutPrograms = try! WorkoutProgram.getAllWorkoutProgramNames()
    }
    
    // MARK: Data source methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutPrograms.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutProgram Cell", for: indexPath)
        if let workoutProgramCell = cell as? WorkoutProgramTableViewCell {
            workoutProgramCell.name = workoutPrograms[indexPath.row]
            workoutProgramCell.delegate = self
        }

        return cell
    }
    
    // MARK: Addition of data
    
    @IBAction func addWorkoutProgram(_ sender: UIBarButtonItem) {
        let newWorkoutProgram = "Untitled".madeUnique(withRespectTo: workoutPrograms)
        workoutPrograms.append(newWorkoutProgram)
        let indexOfNewWorkoutProgram = workoutPrograms.firstIndex(of: newWorkoutProgram)
        WorkoutProgram.addWorkoutProgram(withName: newWorkoutProgram, rowNum: indexOfNewWorkoutProgram!)
        tableView.insertRows(at: [IndexPath(row: indexOfNewWorkoutProgram!, section: 0)], with: .automatic)
    }
    
    // MARK: Editing of table

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView.isEditing
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            workoutPrograms.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        if editing == false, isEditing == true //This means that editing went from true to false i.e. editing ended
        {
            try! WorkoutProgram.synchronize(withData: workoutPrograms)
        }
        super.setEditing(editing, animated: animated)
    }

    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedWorkoutProgram = workoutPrograms.remove(at: fromIndexPath.row)
        workoutPrograms.insert(movedWorkoutProgram, at: to.row)
    }
    
    // MARK: Renaming of data
    
    func didUpdateWorkoutProgramName(from oldName: String, to newName: String, inCell cell: WorkoutProgramTableViewCell) {
        if workoutPrograms.contains(newName) == false {
            let indexPath = tableView.indexPath(for: cell)
            workoutPrograms[indexPath!.row] = newName
            try! WorkoutProgram.updateWorkoutProgramName(from: oldName, to: newName)
        }
        else {
            cell.name = oldName
            alertUserForPreexistingName(whenUpdatingCell: cell)
        }
    }
    
    private func alertUserForPreexistingName(whenUpdatingCell cell: WorkoutProgramTableViewCell) {
        let alert = UIAlertController(title: "Name already exists", message: "Another workout already exists with this name. Enter a different name", preferredStyle: .alert)
        let alertAction_OK = UIAlertAction(title: "Ok", style: .default) { _ in
            cell.receiveNameFromUser()
        }
        alert.addAction(alertAction_OK)
        present(alert, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension String {
    func madeUnique(withRespectTo otherStrings: [String]) -> String {
        var possiblyUnique = self
        var uniqueNumber = 1
        while otherStrings.contains(possiblyUnique) {
            possiblyUnique = self + " \(uniqueNumber)"
            uniqueNumber += 1
        }
        return possiblyUnique
    }
}