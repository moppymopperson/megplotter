//
//  Line.swift
//  Grapher
//
//  Created by Erik Hornberger on 12/22/16.
//  Copyright © 2016 EExT. All rights reserved.
//

import UIKit

/** 
 One line on a `Graph` view. Points will be spaced equidistantly
 and only the Y values need to be specified.
 */
class Line: NSObject {
    
    /// The maximum number of points the line may have
    static let maxLength = 150
    
    /// The Y values of the the points
    var values:[CGFloat]
    
    /// The line's color when plotted
    var color:UIColor = .red
    
    /// The width of the line
    var width:CGFloat = 1
    
    init(values:[CGFloat]){
        self.values = values
        super.init()
    }
    
    /** 
     When a new point is added to a line it is appended to the end.
     If the array exceeds `maxLength` then, the first point is thrown away
     to keep it the right length
     */
    func add(newPoint:CGFloat) {
        if values.count >= Line.maxLength {
            values.remove(at: 0)
        }
        values.append(newPoint)
    }
}
