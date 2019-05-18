//
//  WorkoutProgram.swift
//  WorkoutGo
//
//  Created by Ashish Bansal on 21/04/19.
//  Copyright © 2019 Ashish Bansal. All rights reserved.
//

import UIKit
import CoreData

class WorkoutProgram: NSManagedObject {
    static func getAllWorkoutProgramNames() throws -> [String] {
        let workoutPrograms = try getAllWorkoutPrograms()
        let workoutProgramNames = workoutPrograms.map {
            $0.name ?? "#ERROR"
        }
        return workoutProgramNames
    }
    
    private static func getAllWorkoutPrograms() throws -> [WorkoutProgram] {
        let fetchRequest: NSFetchRequest<WorkoutProgram> = WorkoutProgram.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(WorkoutProgram.rowNum), ascending: true)]
        let workoutPrograms = try AppDelegate.persistentContainer.viewContext.fetch(fetchRequest)
        return workoutPrograms
    }
    
    static func addWorkoutProgram(withName name: String, rowNum: Int) {
        let newWorkoutProgram = WorkoutProgram(context: AppDelegate.persistentContainer.viewContext)
        newWorkoutProgram.name = name
        newWorkoutProgram.rowNum = Int32(rowNum)
    }
    
    static func updateWorkoutProgramName(from oldName: String, to newName: String) throws {
        let workoutProgramForUpdate = try getWorkoutProgram(forName: oldName)
        workoutProgramForUpdate!.name = newName
    }
    
    static func getWorkoutProgram(forName name: String) throws -> WorkoutProgram? {
        let fetchRequest: NSFetchRequest<WorkoutProgram> = WorkoutProgram.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(WorkoutProgram.name), name)
        let workoutPrograms = try AppDelegate.persistentContainer.viewContext.fetch(fetchRequest)
        return workoutPrograms.first
    }
    
    static func synchronize(withData names: [String]) throws {
        var workoutPrograms = try getAllWorkoutPrograms()
        for (index, name) in names.enumerated() {
            let workoutProgramIndex = workoutPrograms.firstIndex { $0.name == name }!
            let workoutProgram = workoutPrograms.remove(at: workoutProgramIndex)
            workoutProgram.rowNum = Int32(index)
        }
        
        workoutPrograms.forEach { AppDelegate.persistentContainer.viewContext.delete($0) }
    }
}
