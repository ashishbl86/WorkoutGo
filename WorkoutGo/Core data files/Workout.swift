//
//  Workout.swift
//  WorkoutGo
//
//  Created by Ashish Bansal on 21/04/19.
//  Copyright © 2019 Ashish Bansal. All rights reserved.
//

import UIKit
import CoreData

class Workout: NSManagedObject {
    static func getAllWorkoutNames(forWorkoutProgram programName: String) throws -> [String] {
        let workouts = try getAllWorkouts(forWorkoutProgram: programName)
        let workoutNames = workouts.map {
            $0.name ?? "#ERROR"
        }
        return workoutNames
    }
    
    private static func getAllWorkouts(forWorkoutProgram programName: String) throws -> [Workout] {
        let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Workout.rowNum), ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Workout.program.name), programName)
        let workouts = try AppDelegate.persistentContainer.viewContext.fetch(fetchRequest)
        return workouts
    }
    
    static func addWorkout(forProgram programName: String, withName name: String, rowNum: Int) throws {
        let newWorkout = Workout(context: AppDelegate.persistentContainer.viewContext)
        newWorkout.name = name
        newWorkout.rowNum = Int32(rowNum)
        let workoutProgram = try WorkoutProgram.getWorkoutProgram(forName: programName)!
        newWorkout.program = workoutProgram
    }
    
    static func updateWorkoutName(forProgram programName: String, from oldName: String, to newName: String) throws {
        let workoutForUpdate = try getWorkout(forProgram: programName, withName: oldName)
        workoutForUpdate!.name = newName
    }
    
    static func getWorkout(forProgram programName: String, withName name: String) throws -> Workout? {
        let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
        let workoutNamePredicate = NSPredicate(format: "%K == %@", #keyPath(Workout.name), name)
        let workoutProgramNamePredicate = NSPredicate(format: "%K == %@", #keyPath(Workout.program.name), programName)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutNamePredicate, workoutProgramNamePredicate])
        let workouts = try AppDelegate.persistentContainer.viewContext.fetch(fetchRequest)
        return workouts.first
    }
    
    static func synchronize(withData names: [String], forProgram programName: String) throws {
        var workouts = try getAllWorkouts(forWorkoutProgram: programName)
        for (index, name) in names.enumerated() {
            let workoutIndex = workouts.firstIndex { $0.name == name }!
            let workout = workouts.remove(at: workoutIndex)
            workout.rowNum = Int32(index)
        }
        
        workouts.forEach { AppDelegate.persistentContainer.viewContext.delete($0) }
    }
}
