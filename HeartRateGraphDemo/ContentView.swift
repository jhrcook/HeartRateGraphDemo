//
//  ContentView.swift
//  HeartRateGraphDemo
//
//  Created by Joshua on 11/1/20.
//

import SwiftUI

struct ContentView: View {
    var workoutTracker  = WorkoutTracker()
    var body: some View {
        HeartRateGraphView(workoutTracker: workoutTracker)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
