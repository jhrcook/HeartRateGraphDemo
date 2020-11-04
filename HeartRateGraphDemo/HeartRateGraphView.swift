//
//  HeartRateGraphView.swift
//  HeartRateGraphDemo
//
//  Created by Joshua on 11/1/20.
//

import SwiftUI


struct HeartRateGraphView: View {
    
    var graphData: HeartRateGraphData

    let numYGridLines = 3
    var yGridValues: [Double] {
        let min = graphData.minY.rounded(.down)
        let max = graphData.maxY.rounded(.up)
        var values = [min, max]
        let gap = ((max - min) / Double(numYGridLines + 1))
        for i in 1...numYGridLines {
            values.append(min + (gap * Double(i)))
        }
        return values
    }
    
    init (workoutTracker: WorkoutTracker) {
        graphData = HeartRateGraphData(workoutTraker: workoutTracker)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                GraphBackgroundSegment(graphData: graphData, geo: geo).opacity(0.3)
                ForEach(yGridValues, id: \.self) { val in
                    PlotHVLines(value: val, horizontal: true, graphData: graphData)
                        .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round, dash: [5]))
                        .opacity(0.5)
                        .padding(10)
                }
                HeartRateGraphPlotShape(graphData: graphData)
                    .stroke(Color.black, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
                    .padding(10)
            }
        }
    }
}


extension Double {
    func rangeMap(inMin: Double, inMax: Double, outMin: Double, outMax: Double) -> Double {
        return (self - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
    }
}


struct HeartRateGraphView_Previews: PreviewProvider {
    static var previews: some View {
        HeartRateGraphView(workoutTracker: WorkoutTracker())
            .previewLayout(.fixed(width: 300, height: 200))
    }
}
