//
//  Exercise.swift
//  WorkoutGo
//
//  Created by Ashish Bansal on 21/04/19.
//  Copyright © 2019 Ashish Bansal. All rights reserved.
//

import UIKit
import CoreData

class Exercise: NSManagedObject {

    static func getAllExerciseInfo(forWorkoutProgram programName: String, forWorkout workoutName: String) throws -> [ExerciseInfo] {
        let exercises = try getAllExercises(forWorkoutProgram: programName, forWorkout: workoutName)
        let exerciseInfoList = exercises.map { exercise -> ExerciseInfo in
            let exerciseInfo = ExerciseInfo(name: exercise.name!, duration: Int(exercise.duration))
            return exerciseInfo
        }
        return exerciseInfoList
    }
    
    private static func getAllExercises(forWorkoutProgram programName: String, forWorkout workoutName: String) throws -> [Exercise] {
        let fetchRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Exercise.rowNum), ascending: true)]
        let programNamePredicate = NSPredicate(format: "%K == %@", #keyPath(Exercise.workout.program.name), programName)
        let workoutNamePredicate = NSPredicate(format: "%K == %@", #keyPath(Exercise.workout.name), workoutName)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [programNamePredicate, workoutNamePredicate])
        let exercises = try AppDelegate.persistentContainer.viewContext.fetch(fetchRequest)
        return exercises
    }
    
    static func addExercise(forWorkoutProgram programName: String, forWorkout workoutName: String, withName name: String, withDuration duration: Int = 30, rowNum: Int) throws {
        let newExercise = Exercise(context: AppDelegate.persistentContainer.viewContext)
        newExercise.name = name
        newExercise.duration = Int32(duration)
        newExercise.workout = try Workout.getWorkout(forProgram: programName, withName: workoutName)
    }
    
    static func updateExercise(forProgram programName: String, forWorkout workoutName: String, at index: Int, to newName: String, withDuration duration: Int) throws {
        let exerciseForUpdate = try getAllExercises(forWorkoutProgram: programName, forWorkout: workoutName)[index]
        exerciseForUpdate.name = newName
        exerciseForUpdate.duration = Int32(duration)
    }
    
    static func synchronize(withData exerciseInfoList: [ExerciseInfo], forProgram programName: String, forWorkout workoutName: String) throws {
        var exercises = try getAllExercises(forWorkoutProgram: programName, forWorkout: workoutName)
        for (index, exerciseInfo) in exerciseInfoList.enumerated() {
            let exerciseIndex = exercises.firstIndex { $0.name == exerciseInfo.name }!
            let exercise = exercises.remove(at: exerciseIndex)
            exercise.rowNum = Int32(index)
        }
        
        exercises.forEach {
            AppDelegate.persistentContainer.viewContext.delete($0)
        }
    }
}
