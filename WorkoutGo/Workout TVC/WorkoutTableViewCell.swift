//
//  WorkoutTableViewCell.swift
//  WorkoutGo
//
//  Created by Ashish Bansal on 24/04/19.
//  Copyright © 2019 Ashish Bansal. All rights reserved.
//

import UIKit

protocol WorkoutTableViewCellDelegate: AnyObject {
    func didUpdateWorkoutName(from: String, to: String, inCell: WorkoutTableViewCell)
}

class WorkoutTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var workoutNameTextField: UITextField! {
        didSet {
            workoutNameTextField.delegate = self
        }
    }
    
    weak var delegate: WorkoutTableViewCellDelegate!
    
    var name: String {
        get {
            return workoutNameTextField.text!
        }
        set {
            workoutNameTextField.text = newValue
        }
    }
    
    private var previousText = ""
    
    func receiveNameFromUser() {
        previousText = workoutNameTextField.text!
        workoutNameTextField.isEnabled = true
        workoutNameTextField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.isEnabled = false
        let newText = workoutNameTextField.text!
        if newText.isEmpty {
            workoutNameTextField.text = previousText
        }
        
        if previousText != newText {
            delegate.didUpdateWorkoutName(from: previousText, to: newText, inCell: self)
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
