//
//  CenteredTextLayer.swift
//  Tokens
//
//  Created by Paul on 23/07/2016.
//  Copyright © 2016 Paul Sneddon. All rights reserved.
//

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

#if !os(watchOS)
public class CenteredTextLayer : CATextLayer {
    
    override public init() {
        super.init()
    }
    
    override init(layer: AnyObject) {
        super.init(layer: layer)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(layer: aDecoder)
    }
    
    override public func draw(in ctx: CGContext) {
        let height = self.bounds.size.height
        let fontSize = self.fontSize
        
        #if os(iOS)
            let yDiff = (height-fontSize)/2 - fontSize/10
        #else
            let yDiff = (height-fontSize*2)/2 - fontSize/10
        #endif
        
        ctx.saveGState()
        ctx.translateBy(x: 0.0, y: yDiff)
        super.draw(in: ctx)
        ctx.restoreGState()
    }
}
#endif
