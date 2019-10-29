//
//  AddWorkout_ExerciseViewController.swift
//  WorkoutGo
//
//  Created by Ashish Bansal on 25/10/19.
//  Copyright © 2019 Ashish Bansal. All rights reserved.
//

import UIKit

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

protocol Add_Edit_WorkoutExerciseDelegate {
    var workoutNameSendAction: ((String) -> Void)? { get }
    var exerciseInfoSendAction: ((ExerciseInfo) -> Void)? { get }
    func canAcceptName(_ name: String) -> (answer: Bool, errorMessage: String)
}

class Add_Edit_WorkoutExercise_ViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    class func calculateTimeComponents(for timeInSecs: Int) -> (mins: Int, secs: Int) {
        let seconds = timeInSecs % 60
        let minutes = timeInSecs / 60
        return (minutes, seconds)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var prefixString = ""
        if row < 10 {
            prefixString = "0"
        }
        
        return "\(prefixString)\(row)"
    }
    
    enum OperationType {
        case workout, exercise
    }
    
    var delegate: Add_Edit_WorkoutExerciseDelegate?
    var previousWorkoutName = ""
    var previousExerciseInfo = ExerciseInfo(name: "", duration: 0)
    var operationType = OperationType.workout
    
    @IBOutlet weak var workoutExerciseNameTextField: UITextField!{
        didSet {
            workoutExerciseNameTextField.delegate = self
        }
    }
    
    @IBOutlet weak var viewAboveNavBar: UIView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var operationNameLabel: UILabel!
    @IBOutlet weak var minutesPickerView: UIPickerView! {
        didSet {
            minutesPickerView.dataSource = self
            minutesPickerView.delegate = self
        }
    }
    @IBOutlet weak var secondsPickerView: UIPickerView! {
           didSet {
               secondsPickerView.dataSource = self
               secondsPickerView.delegate = self
           }
       }
    @IBOutlet weak var exerciseDurationContainerView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Modal - Status bar navigation style: \(preferredStatusBarStyle.rawValue).")
        
        navBar.topItem?.title = title

        switch operationType {
        case .workout:
            exerciseDurationContainerView.isHidden = true
            operationNameLabel.text = "Workout Name"
            workoutExerciseNameTextField.placeholder = "Enter Workout Name"
            workoutExerciseNameTextField.text = previousWorkoutName
            workoutExerciseNameTextField.becomeFirstResponder()
            
        case .exercise:
            exerciseDurationContainerView.isHidden = false
            operationNameLabel.text = "Exercise Name"
            workoutExerciseNameTextField.placeholder = "Enter Exercise Name"
            workoutExerciseNameTextField.text = previousExerciseInfo.name
            let durationComponents = Add_Edit_WorkoutExercise_ViewController.calculateTimeComponents(for: previousExerciseInfo.duration)
            minutesPickerView.selectRow(durationComponents.mins, inComponent: 0, animated: false)
            secondsPickerView.selectRow(durationComponents.secs, inComponent: 0, animated: false)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if previousWorkoutName != workoutExerciseNameTextField.text {
            let newText = workoutExerciseNameTextField.text ?? ""
            
            let checkResult = delegate?.canAcceptName(newText) ?? (answer: true, errorMessage: "")
            if checkResult.answer == false {
                alertForFailure(withMessage: checkResult.errorMessage)
                return false
            }
        }
        
        workoutExerciseNameTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            workoutExerciseNameTextField.text = previousWorkoutName
        }
    }
    
    private func alertForFailure(withMessage alertMessage: String) {
        let alert = UIAlertController(title: "Unable to use this name", message: alertMessage, preferredStyle: .alert)
        let alertAction_OK = UIAlertAction(title: "Re-enter", style: .default)
        alert.addAction(alertAction_OK)
        present(alert, animated: true)
    }

    
    @IBAction func done(_ sender: UIBarButtonItem) {
        switch operationType {
        case .workout:
            if previousWorkoutName != workoutExerciseNameTextField.text {
                if let delegateWorkoutNameAction = delegate?.workoutNameSendAction {
                    delegateWorkoutNameAction(workoutExerciseNameTextField.text!)
                }
            }
        
        case .exercise:
            let durationInSecs = (minutesPickerView.selectedRow(inComponent: 0) * 60) + secondsPickerView.selectedRow(inComponent: 0)
            let updatedExerciseInfo = ExerciseInfo(name: workoutExerciseNameTextField.text!, duration: durationInSecs)
            if previousExerciseInfo != updatedExerciseInfo {
                if let delegateExerciseInfoAction = delegate?.exerciseInfoSendAction {
                    delegateExerciseInfoAction(updatedExerciseInfo)
                }
            }
        }
        presentingViewController?.dismiss(animated: true)
    }
    

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true)
    }
}
