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
        values.sort { $0 > $1 }
        return values
    }
    
    var gridTextWidth: CGFloat = 14
    var verticalPadding: CGFloat = 10
    
    init (workoutTracker: WorkoutTracker) {
        graphData = HeartRateGraphData(workoutTraker: workoutTracker)
    }
    
    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .center, spacing: 0) {
                ZStack {
                    ForEach(yGridValues, id: \.self) { val in
                        PlotHVGridText(value: val, horizontal: true, graphData: graphData, size: reduceGeoSize(geo, heightBy: verticalPadding * 2))
                            .padding(0)
                    }
                    .frame(width: gridTextWidth)
                    .padding(.vertical, verticalPadding)
                }
                ZStack {
                    GraphBackgroundSegment(graphData: graphData, size: reduceGeoSize(geo, widthBy: gridTextWidth))
                        .opacity(0.3)
                    ForEach(yGridValues, id: \.self) { val in
                        PlotHVLines(value: val, horizontal: true, graphData: graphData)
                            .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round, dash: [3]))
                            .opacity(0.5)
                            .padding(.vertical, verticalPadding)
                            .padding(.horizontal, 3)
                    }
                    HeartRateGraphPlotShape(graphData: graphData)
                        .stroke(Color.black, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
                        .padding(verticalPadding)
                }
            }
        }
    }
    
    
    func reduceGeoSize(_ geo: GeometryProxy, widthBy widthAdjust: CGFloat = 0, heightBy heightAdjust: CGFloat = 0) -> CGSize {
        var modSize = geo.size
        modSize.width = modSize.width - widthAdjust
        modSize.height = modSize.height - heightAdjust
        return modSize
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
            .padding(5)
            .previewLayout(.fixed(width: 300, height: 200))
    }
}
