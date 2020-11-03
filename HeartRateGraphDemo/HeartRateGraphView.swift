//
//  HeartRateGraphView.swift
//  HeartRateGraphDemo
//
//  Created by Joshua on 11/1/20.
//

import SwiftUI

struct HeartRateGraphDatum {
    let x: Double
    let y: Double
    let groupIndex: Int
}

struct HeartRateGraphData {
    var data: [HeartRateGraphDatum]
    
    var minX: Double {
        return data.map { $0.x }.min()!
    }
    var minY: Double {
        return data.map { $0.y }.min()!
    }
    var maxX: Double {
        return data.map { $0.x }.max()!
    }
    var maxY: Double {
        return data.map { $0.y }.max()!
    }
    
    init(workoutTraker: WorkoutTracker) {
        self.data = HeartRateGraphData.workoutTrackerDataToGraphData(workoutTraker)
    }
    
    static func workoutTrackerDataToGraphData(_ workoutTracker: WorkoutTracker) -> [HeartRateGraphDatum] {
        var HRData = [HeartRateGraphDatum]()
        
        var xIdx: Double = 0.0
        for (dataIdx, data) in workoutTracker.data.enumerated() {
            for hr in data.heartRate {
                xIdx += 1.0
                HRData.append(HeartRateGraphDatum(x: xIdx, y: hr, groupIndex: dataIdx))
            }
        }
        
        return HRData
    }
    
    func convertedXData(toMin: Double, toMax: Double) -> [Double] {
        return data.map { convert(x: $0.x, toMin: toMin, toMax: toMax) }
    }
    
    func convertedYData(toMin: Double, toMax: Double) -> [Double] {
        return data.map { convert(y: $0.y, toMin: toMin, toMax: toMax) }
    }
    
    func convert(x: Double, toMin: Double, toMax: Double) -> Double {
        return x.rangeMap(inMin: self.minX, inMax: self.maxX, outMin: toMin, outMax: toMax)
    }
    
    func convert(y: Double, toMin: Double, toMax: Double) -> Double {
        return y.rangeMap(inMin: self.minY, inMax: self.maxY, outMin: toMin, outMax: toMax)
    }
}


struct HeartRateGraphPlotShape: Shape {
    
    let graphData: HeartRateGraphData
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = Double(rect.size.width)
        let height = Double(rect.size.height)
        
        let xData = graphData.convertedXData(toMin: 0.0, toMax: width)
        let yData = graphData.convertedYData(toMin: height, toMax: 0.0)
        
        path.move(to: CGPoint(x: xData[0], y: yData[0]))
        for (x, y) in zip(xData, yData) {
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return path
    }
}

struct PlotHVLines: Shape {
    
    let value: Double
    let horizontal: Bool
    let graphData: HeartRateGraphData
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = Double(rect.size.width)
        let height = Double(rect.size.height)
        var mappedValue = 0.0
        
        if horizontal {
            mappedValue = graphData.convert(y: value, toMin: height, toMax: 0)
        } else {
            mappedValue = graphData.convert(x: value, toMin: 0, toMax: width)
        }
        
        path.move(to: CGPoint(x: horizontal ? 0 : mappedValue, y: horizontal ? mappedValue : 0))
        path.addLine(to: CGPoint(x: horizontal ? width : 0, y: horizontal ? mappedValue : 0))
        
        return path
    }
}

struct GraphBackgroundSegment: View {
    
    var graphData: HeartRateGraphData
    var geo: GeometryProxy
    var segmentData: [RectangleSegment]
    
    var totalSegmentWidth: Double {
        return segmentData.reduce(0, { $0 + $1.width })
    }
    
    var maxSegmentHeight: Double {
        return segmentData.map { $0.height }.max()!
    }
    
    init(graphData: HeartRateGraphData, geo: GeometryProxy) {
        self.graphData = graphData
        self.geo = geo
        segmentData = GraphBackgroundSegment.makeSegmentData(from: graphData)
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(0..<segmentData.count) { i in
                Rectangle()
                    .frame(
                        width: scaleWidth(segmentData[i].width),
                        height: scaleHeight(segmentData[i].height))
                    .foregroundColor(segmentData[i].color)
            }
        }
    }
    
    func scaleWidth(_ width: Double) -> CGFloat {
        CGFloat(width.rangeMap(inMin: 0, inMax: totalSegmentWidth, outMin: 0, outMax: Double(geo.size.width)))
    }
    
    func scaleHeight(_ height: Double) -> CGFloat {
        CGFloat(height.rangeMap(inMin: 0, inMax: maxSegmentHeight, outMin: 0, outMax: Double(geo.size.height)))
    }
    
    struct RectangleSegment {
        let width: Double
        let height: Double
        let color: Color
    }
    
    static func makeSegmentData(from graphData: HeartRateGraphData) -> [RectangleSegment] {
        var data = [RectangleSegment]()
        let groupIndices = Array(Set(graphData.data.map { $0.groupIndex })).sorted()
        let colors: [Color] = colorArray(numberOfColors: groupIndices.count)
        
        for idx in groupIndices {
            let xValues = graphData.data.filter { $0.groupIndex == idx }.map { $0.x }
            let minX = xValues.min()!
            let maxX = xValues.max()!
            let minY = graphData.minY
            let maxY = graphData.maxY
            data.append(RectangleSegment(width: maxX - minX, height: maxY - minY, color: colors[idx]))
        }
        
        return data
    }
    
    static func colorArray(numberOfColors n: Int) -> [Color] {
        var colors = [Color]()
        
        let jump = 3.0 / Double(n)
        var val: Double = 0
        for _ in 0..<n {
            if val <= 1 {
                colors.append(Color(red: 1 - val, green: val, blue: 0))
            } else if val <= 2 {
                colors.append(Color(red: 0, green: 1 - (val - 1), blue: (val - 1)))
            } else {
                colors.append(Color(red: val - 2, green: 0, blue: 1 - (val - 2)))
            }
            val += jump
        }
        
        return colors
    }
}


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
