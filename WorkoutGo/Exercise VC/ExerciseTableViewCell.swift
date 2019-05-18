//
//  ExerciseTableViewCell.swift
//  WorkoutGo
//
//  Created by Ashish Bansal on 25/04/19.
//  Copyright © 2019 Ashish Bansal. All rights reserved.
//

import UIKit

protocol ExerciseTableViewCellDelegate: AnyObject {
    func didUpdateExerciseName(from: String, to: String, inCell: ExerciseTableViewCell)
}

class ExerciseTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var exerciseNameTextField: UITextField! {
        didSet {
            exerciseNameTextField.delegate = self
        }
    }
    
    @IBOutlet weak var durationLabel: UILabel!
    
    weak var delegate: ExerciseTableViewCellDelegate!
    
    var exerciseInfo: ExerciseInfo! {
        didSet {
            exerciseNameTextField.text = exerciseInfo.name
            durationLabel.text = DateComponentsFormatter.common.string(from: Double(exerciseInfo.duration))
        }
    }

    private var previousText = ""
    
    func receiveNameFromUser() {
        previousText = exerciseNameTextField.text!
        exerciseNameTextField.isEnabled = true
        exerciseNameTextField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.isEnabled = false
        let newText = exerciseNameTextField.text!
        if newText.isEmpty {
            exerciseNameTextField.text = previousText
        }
        
        if previousText != newText {
            delegate.didUpdateExerciseName(from: previousText, to: newText, inCell: self)
        }
    }
    
    @objc private func doubleTapPerformed(recognizer: UITapGestureRecognizer) {
        receiveNameFromUser()
    }
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addDoubleTapGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addDoubleTapGesture()
    }
    
    private func addDoubleTapGesture() {
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapPerformed(recognizer:)))
        doubleTapGesture.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapGesture)
    }

}
