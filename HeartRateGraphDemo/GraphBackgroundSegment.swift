//
//  GraphBackgroundSegment.swift
//  HeartRateGraphDemo
//
//  Created by Joshua on 11/4/20.
//

import SwiftUI

struct GraphBackgroundSegment: View {
    
    var graphData: HeartRateGraphData
    var size: CGSize
    var segmentData: [RectangleSegment]
    
    var totalSegmentWidth: Double {
        return segmentData.reduce(0, { $0 + $1.width })
    }
    
    var maxSegmentHeight: Double {
        return segmentData.map { $0.height }.max()!
    }
    
    init(graphData: HeartRateGraphData, size: CGSize) {
        self.graphData = graphData
        self.size = size
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
    
    
    /// Scale a value to the width of the entire frame.
    /// - Parameter width: Width to be scaled.
    /// - Returns: Scaled width.
    func scaleWidth(_ width: Double) -> CGFloat {
        CGFloat(width.rangeMap(inMin: 0, inMax: totalSegmentWidth, outMin: 0, outMax: Double(size.width)))
    }
    
    
    /// Scale a value to the height of the entire frame.
    /// - Parameter height: Height to be scaled.
    /// - Returns: Scaled height.
    func scaleHeight(_ height: Double) -> CGFloat {
        CGFloat(height.rangeMap(inMin: 0, inMax: maxSegmentHeight, outMin: 0, outMax: Double(size.height)))
    }
    
    
    struct RectangleSegment {
        let width: Double
        let height: Double
        let color: Color
    }
    
    
    /// Create the data for building the segments.
    /// - Parameter graphData: The graph data.
    /// - Returns: The segment data.
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
    
    
    /// Create an array of colors across the complete rainbow.
    /// - Parameter n: The number of colors to create.
    /// - Returns: An array of SwiftUI `Color` views.
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
