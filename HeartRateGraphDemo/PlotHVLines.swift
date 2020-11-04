//
//  PlotHVLines.swift
//  HeartRateGraphDemo
//
//  Created by Joshua on 11/4/20.
//

import SwiftUI

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
