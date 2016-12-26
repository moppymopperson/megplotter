//
//  Graph.swift
//  Grapher
//
//  Created by Erik Hornberger on 12/22/16.
//  Copyright © 2016 EExT. All rights reserved.
//

import UIKit

/** 
 A view that owns and draws `Line`s. Any number of lines can be plotted, but
 all lines must have the same number of points. Lines are all plotted on the 
 same axis, like a butterfly plot.
 */
class Graph: UIView {

    /// The lines that will be draw
    let lines:[Line]
    
    /// The X values of the points being plotted. Calculated when the lines are set.
    internal let xValues:[CGFloat]
    
    /// The max value of Y that the `Line`s will contain. Must be known a priori.
    internal let maxY:CGFloat = 1
    
    /// The location of 0 on the Y axis.
    internal let y0:CGFloat
    
    /// The values in each `Line` are multiplied by `yScale` so that `maxY`
    /// precisly reaches the top of the view
    internal let yScale:CGFloat

    init(frame:CGRect, lines:[Line]) {
        self.lines   = lines
        
        // Array of linearly spaced x values across the view's width
        self.xValues = {
            var x = [CGFloat]()
            let step = frame.width / CGFloat(lines[0].values.count)
            for k in 0..<lines[0].values.count {
                x.append(CGFloat(k)*step)
            }
            return x
        }()
        
        // y0 in the middle of the view
        self.y0 = frame.height / 2
        
        // Set scale so that `maxY` exactly reaches the top
        self.yScale = (frame.height / 2) / maxY
        super.init(frame: frame)
        self.backgroundColor = .darkGray
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Each time the view is drawn, plot each line
    override func draw(_ rect: CGRect) {
        for line in lines {
            plot(line)
        }
    }
    
    /// Plot one line on the view
    func plot(_ line:Line) {
        
        let path = UIBezierPath()
        path.lineWidth = line.width
        
        // Draw a line from one point to the next, for all points
        for k in 0..<line.values.count - 1 {
            path.move(to: CGPoint(x: xValues[k], y: y0 - line.values[k] * yScale))
            path.addLine(to: CGPoint(x: xValues[k+1], y: y0 - line.values[k+1] * yScale))
        }
        
        // Draw a circle on the far right, last point
        let circlePath = UIBezierPath(arcCenter: path.currentPoint, radius: 4, startAngle: 0, endAngle: 2*3.1415, clockwise: true)
        
        // Color and fill
        line.color.setStroke()
        line.color.setFill()
        path.stroke()
        circlePath.fill()
    }
}
