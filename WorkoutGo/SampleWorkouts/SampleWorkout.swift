//
//  SampleWorkout.swift
//  WorkoutGo
//
//  Created by Ashish Bansal on 28/02/20.
//  Copyright © 2020 Ashish Bansal. All rights reserved.
//

import Foundation

class SampleWorkout: Decodable {
    var name: String = ""
    var exercises = [SampleExercise]()
    
    private enum CodingKeys: String, CodingKey {
        case workout = "Workout"
        case exercises = "Exercises"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .workout)
        exercises = try container.decode([SampleExercise].self, forKey: .exercises)
    }
    
    static func loadFrom(jsonFile: String) -> [SampleWorkout]? {
        guard let fileUrl = Bundle.main.url(forResource: jsonFile, withExtension: nil)
            else {
                return nil
        }
        guard let jsonData = try? Data(contentsOf: fileUrl)
            else {
                return nil
        }
        let sampleWorkouts = try? JSONDecoder().decode([SampleWorkout].self, from: jsonData)
        return sampleWorkouts
    }
}

class SampleExercise: Decodable {
    var name: String = ""
    var duration: Int = 0
    
    private enum CodingKeys: String, CodingKey {
        case name = "Exercise"
        case duration = "Duration"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        duration = try container.decode(Int.self, forKey: .duration)
    }
}
