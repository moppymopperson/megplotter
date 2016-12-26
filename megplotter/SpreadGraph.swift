//
//  SpreadGraph.swift
//  Grapher
//
//  Created by Erik Hornberger on 12/24/16.
//  Copyright © 2016 EExT. All rights reserved.
//

import Foundation
import UIKit

/** 
 A view that owns and draws `Line`s. Any number of lines can be plotted, but
 all lines must have the same number of points. Lines are all plotted on their
 own axii, spread out vertically.
 */
class SpreadGraph: Graph {
        
    override func plot(_ line: Line) {
        
        let path = UIBezierPath()
        path.lineWidth = line.width
        
        // Scale so that all lines fit onscreen when vertically stacked
        let yScale = bounds.height / CGFloat(lines.count) * CGFloat(maxY)
        
        // Draw a line from point to point all the way to the end
        for k in 0..<line.values.count - 1 {
            let lineIndex = lines.index(of: line)!
            let verticalOffset = yScale/2 + CGFloat(lineIndex) * yScale
            path.move(to: CGPoint(x: xValues[k], y: verticalOffset - line.values[k] * yScale))
            path.addLine(to: CGPoint(x: xValues[k+1], y: verticalOffset - line.values[k+1] * yScale))
        }
        
        // Draw a circle on the last point on the right
        let circlePath = UIBezierPath(arcCenter: path.currentPoint, radius: 4, startAngle: 0, endAngle: 2*3.1415, clockwise: true)
        
        // Fill and color
        line.color.setStroke()
        line.color.setFill()
        path.stroke()
        circlePath.fill()
    }
}
