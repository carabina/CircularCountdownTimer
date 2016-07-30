//
//  NSBezierPath+Extensions.swift
//  CountdownTimerView
//
//  Created by Paul on 30/07/2016.
//  Copyright © 2016 Paul Sneddon. All rights reserved.
//


#if os(OSX)
import AppKit
#endif

#if os(OSX)
    extension NSBezierPath {
        func toCGPath () -> CGPath? {
            if self.elementCount == 0 {
                return nil
            }
            
            let path = CGMutablePath()
            var didClosePath = false
            
            for i in 0...self.elementCount-1 {
                var points = [NSPoint](repeating: NSZeroPoint, count: 3)
                
                switch self.element(at: i, associatedPoints: &points) {
                case .moveToBezierPathElement:path.moveTo(nil, x: points[0].x, y: points[0].y)
                case .lineToBezierPathElement:path.addLineTo(nil, x: points[0].x, y: points[0].y)
                case .curveToBezierPathElement:path.addCurve(nil, cp1x: points[0].x, cp1y: points[0].y, cp2x: points[1].x, cp2y: points[1].y, endingAtX: points[2].x, y: points[2].y)
                case .closePathBezierPathElement:path.closeSubpath()
                didClosePath = true;
                }
            }
            
            if !didClosePath {
                path.closeSubpath()
            }
            
            return path.copy()
        }
    }
#endif
