//
//  WorkoutProgramTableViewCell.swift
//  WorkoutGo
//
//  Created by Ashish Bansal on 21/04/19.
//  Copyright © 2019 Ashish Bansal. All rights reserved.
//

import UIKit

protocol WorkoutProgramTableViewCellDelegate: AnyObject {
    func didUpdateWorkoutProgramName(from: String, to: String, inCell: WorkoutProgramTableViewCell)
}

class WorkoutProgramTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var programNameTextField: UITextField! {
        didSet {
            programNameTextField.delegate = self
        }
    }
    
    weak var delegate: WorkoutProgramTableViewCellDelegate!
    
    var name: String {
        get {
            return programNameTextField.text!
        }
        set {
            programNameTextField.text = newValue
        }
    }
    
    private var previousText = ""
    
    func receiveNameFromUser() {
        previousText = programNameTextField.text!
        programNameTextField.isEnabled = true
        programNameTextField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.isEnabled = false 
        let newText = programNameTextField.text!
        if newText.isEmpty {
            programNameTextField.text = previousText
        }
        
        if previousText != newText {
            delegate.didUpdateWorkoutProgramName(from: previousText, to: newText, inCell: self)
        }
    }
    
    @objc private func doubleTapPerformed(recognizer: UITapGestureRecognizer) {
        receiveNameFromUser()
    }
    
    // MARK: Initialization
    
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
