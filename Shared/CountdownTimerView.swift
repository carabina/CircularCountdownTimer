//
//  CountdownTimerView.swift
//  CountdownTimerView
//
//  Created by Paul on 30/07/2016.
//  Copyright © 2016 Paul Sneddon. All rights reserved.
//

// Allow the class to be used with both UIKit and AppKit
#if os(iOS)
    import UIKit
    public typealias UXView = UIView
    public typealias UXColor = UIColor
    public typealias UXWindow = UIWindow
    public typealias UXFont = UIFont
#elseif os(OSX)
    import AppKit
    public typealias UXView = NSView
    public typealias UXColor = NSColor
    public typealias UXWindow = NSWindow
    public typealias UXFont = NSFont
#endif

public protocol TimerDelegate: class {
    func timerDidEnd()
}

@IBDesignable
public class CountdownTimerView: UXView {
    
    // Allow the class to be used with both UIKit and AppKit
    #if os(iOS)
    let scaleFactor = UIScreen.main().scale
    let UXFontWeightMedium = UIFontWeightMedium
    #elseif os(OSX)
    let scaleFactor = NSScreen.main()?.backingScaleFactor ?? 1
    let UXFontWeightMedium = NSFontWeightMedium

    #endif
    
    private var _timer: Timer?
    private var _timerDuration: Int?
    private var progress: Double?
    
    @IBInspectable public var timerDuration:Int = 30 {
        didSet {
            self._timerDuration =  min(timerDuration, 60)
            self.updateTimer()
        }
    }
    
    var remainingTime: Double {
        get {
            let unixTimestamp = NSDate().timeIntervalSince1970
            let interval = unixTimestamp / Double(self.timerDuration)
            
            let lastInterval = floor(unixTimestamp/Double(self.timerDuration))
            let nextInternal = lastInterval+1
            
            let timeToNextInternal = (nextInternal - interval) * Double(self.timerDuration)
            return timeToNextInternal
        }
    }
    
    public weak var delegate: TimerDelegate?
    
    private let baseLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let centreLayer = CAShapeLayer()
    private let borderLayer = CAShapeLayer()
    private let textLayer = CenteredTextLayer()
    
    
    var borderColor: UXColor? {
        get {
            return UXColor(cgColor: borderLayer.strokeColor!)
            
        }
        set {
            borderLayer.strokeColor = newValue?.cgColor
            centreLayer.strokeColor = newValue?.cgColor
        }
    }
    
    private let _defaultColor = UXColor.red
    
    private var _inheritColor = true
    
    var inheritBackgroundColorFromProgressColor: Bool {
        get {
            return _inheritColor
        }
        set {
            _inheritColor = newValue
            setTimerBackgroundColor()
        }
    }
    
    public var progressColor: UXColor? {
        get {
            return UXColor(cgColor: progressLayer.strokeColor ?? self._defaultColor.cgColor)
        }
        set {
            progressLayer.strokeColor = newValue?.cgColor
            setTimerBackgroundColor()
        }
    }
    
    private var _progressBackgroundColor: UXColor?
    public var progressBackgroundColor: UXColor? {
        get {
            if _inheritColor == true {
                return progressColor?.withAlphaComponent(0.2) ?? _defaultColor.withAlphaComponent(0.2)
            } else {
                return UXColor(cgColor: _progressBackgroundColor?.cgColor ?? progressColor?.withAlphaComponent(0.2).cgColor ?? _defaultColor.withAlphaComponent(0.2).cgColor)
            }
        }
        set {
            _progressBackgroundColor = newValue
            setTimerBackgroundColor()
        }
    }
    
    private var maxSize: CGFloat  {
        get {
            return min(self.frame.size.height, self.frame.size.width)
        }
    }
    
    private var masterRect: CGRect {
        get {
            return CGRect(x: 0, y: 0, width: maxSize, height: maxSize)
        }
    }
    
    var centerPoint: CGPoint {
        get {
            return CGPoint(x: masterRect.width/2 , y: masterRect.height/2)
        }
    }
    
    let startAngle = CGFloat(-90 * M_PI / 180)
    let endAngle = CGFloat(270 * M_PI / 180)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayers()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTimerLabel), name: NSNotification.Name(rawValue: GlobalTimer.Notifications.Second.rawValue), object: nil)
    }
    
    private func setupDefaultColors() {
        self.borderColor = UXColor.darkGray
        setTimerBackgroundColor()
    }
    
    private func setTimerBackgroundColor() {
        if _inheritColor == true {
            backgroundLayer.fillColor = progressColor?.withAlphaComponent(0.2).cgColor
        } else {
            backgroundLayer.fillColor = _progressBackgroundColor?.cgColor ?? _defaultColor.withAlphaComponent(0.2).cgColor
        }
        // Update the animations to use the correct colors
        animate()
    }
    
    private func setupLayers() {
        setupDefaultColors()
        
        // Base Layer
        baseLayer.fillColor = UXColor.white.cgColor
        baseLayer.contentsScale = scaleFactor
        
        // Background Layer
        backgroundLayer.contentsScale = scaleFactor
        
        // Border Layer
        borderLayer.lineWidth = 1
        borderLayer.fillColor = UXColor.clear.cgColor
        borderLayer.contentsScale = scaleFactor
        
        // Progress Layer
        progressLayer.backgroundColor = UXColor.clear.cgColor
        progressLayer.fillColor = UXColor.clear.cgColor
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = 1
        progressLayer.contentsScale = scaleFactor
        
        //Centre Layer
        centreLayer.lineWidth = 1
        centreLayer.fillColor = UXColor.white.cgColor
        centreLayer.contentsScale = scaleFactor
        
        //Text Layer
        textLayer.foregroundColor = UXColor.black.cgColor
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.contentsScale = scaleFactor
        
        
        // Add the layers to the view
        #if os(iOS)
            let mainLayer = self.layer
        #elseif os(OSX)
            self.wantsLayer = true
            let mainLayer = self.layer!
        #endif
        
        mainLayer.addSublayer(baseLayer)
        mainLayer.addSublayer(backgroundLayer)
        mainLayer.addSublayer(progressLayer)
        mainLayer.addSublayer(borderLayer)
        mainLayer.addSublayer(centreLayer)
        mainLayer.addSublayer(textLayer)
    }
    
    private func updateTimer() {
        let lockQueue = DispatchQueue(label: "com.paulsneddon.timer.lock_queue")
        lockQueue.sync() {
            // Calculate the progress bar, and if it's less than 1 degree then round it down to 0
            self.progress = (1.0 - (Double(self.remainingTime) / Double(self.timerDuration)))
            self.animate()
        }
    }
    
    func updateTimerLabel() {
        textLayer.string = Int(ceil(self.remainingTime)).description
    }
    
    
    override public func awakeFromNib() {
        super.awakeFromNib()
    }
    
    #if os(iOS)
    override public func layoutSubviews() {
        super.layoutSubviews()
        // When the view is not in the foreground, the animations get removed. This is a workaround to ensure they are resumed
        if progressLayer.animationKeys() == nil {
            updateTimer()
        }
        let fontSize = self.maxSize / 3.5
        textLayer.font = UXFont.monospacedDigitSystemFont(ofSize: fontSize,weight: UXFontWeightMedium)
        textLayer.fontSize = fontSize
    
        borderLayer.path = UIBezierPath(ovalIn: CGRect(x: 1, y: 1, width: maxSize-2, height: maxSize-2)).cgPath
        baseLayer.path = UIBezierPath(ovalIn: CGRect(x: 1, y: 1, width: maxSize-2, height: maxSize-2)).cgPath
        backgroundLayer.path = UIBezierPath(ovalIn: CGRect(x: 1, y: 1, width: maxSize-2, height: maxSize-2)).cgPath
        progressLayer.path = UIBezierPath(arcCenter:centerPoint, radius: (masterRect.width/4), startAngle: startAngle, endAngle:endAngle, clockwise: true).cgPath
        progressLayer.lineWidth = (masterRect.width/2)-2
        centreLayer.path = UIBezierPath(ovalIn: CGRect(x: maxSize/4, y: maxSize/4, width: maxSize/2, height: maxSize/2)).cgPath
        textLayer.frame = CGRect(x: maxSize/4, y: maxSize/4, width: maxSize/2, height: maxSize/2)
        updateTimerLabel()
    }
    #elseif os(OSX)
    override public func layout() {
        super.layout()
        // When the view is not in the foreground, the animations get removed. This is a workaround to ensure they are resumed
        if progressLayer.animationKeys() == nil {
            updateTimer()
        }
        let fontSize = self.maxSize / 3.5
        textLayer.font = UXFont.monospacedDigitSystemFont(ofSize: fontSize,weight: UXFontWeightMedium)
        textLayer.fontSize = fontSize
        
        borderLayer.path = NSBezierPath(ovalIn: CGRect(x: 1, y: 1, width: maxSize-2, height: maxSize-2)).toCGPath()
        baseLayer.path = NSBezierPath(ovalIn: CGRect(x: 1, y: 1, width: maxSize-2, height: maxSize-2)).toCGPath()
        backgroundLayer.path = NSBezierPath(ovalIn: CGRect(x: 1, y: 1, width: maxSize-2, height: maxSize-2)).toCGPath()
        
        let progressPath = NSBezierPath()
        progressPath.appendArc(withCenter: centerPoint, radius: (masterRect.width/4), startAngle: startAngle+90, endAngle: endAngle+90, clockwise: true)
        progressLayer.path = progressPath.toCGPath()
        
        progressLayer.lineWidth = (masterRect.width/2)-2
        centreLayer.path = NSBezierPath(ovalIn: CGRect(x: maxSize/4, y: maxSize/4, width: maxSize/2, height: maxSize/2)).toCGPath()
        textLayer.frame = CGRect(x: maxSize/4, y: maxSize/4, width: maxSize/2, height: maxSize/2)
        updateTimerLabel()
    }
    #endif
}

// MARK : Core Animation Functions

extension CountdownTimerView {
    private func animate() {
        // First clear any running animations
        self.clearAnimations()
        
        // Setup the progress animation
        let pathAnimation: CABasicAnimation = CABasicAnimation(keyPath: "strokeStart")
        pathAnimation.beginTime = CACurrentMediaTime() - (Double(timerDuration) - self.remainingTime)
        pathAnimation.duration = Double(timerDuration) //Double(self.remainingTime)
        pathAnimation.fromValue = 0
        pathAnimation.toValue = 1
        pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        progressLayer.strokeStart = 1
        pathAnimation.delegate = self
        
        // Setup the background fade animation
        let fadeAnimation: CABasicAnimation = CABasicAnimation(keyPath: "fillColor")
        fadeAnimation.duration = 1
        fadeAnimation.beginTime = CACurrentMediaTime()+(Double(self.remainingTime)-1)
        fadeAnimation.delegate = self
        fadeAnimation.fromValue = progressBackgroundColor?.cgColor
        fadeAnimation.toValue = progressColor?.cgColor
        fadeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        fadeAnimation.isRemovedOnCompletion = false
        fadeAnimation.fillMode = kCAFillModeForwards
        
        // Add Animations
        progressLayer.add(pathAnimation, forKey: "progressAnimation")
        backgroundLayer.add(fadeAnimation, forKey: "colourAnimation")
    }
    
    private func clearAnimations() {
        progressLayer.removeAllAnimations()
        backgroundLayer.removeAllAnimations()
    }
}

// MARK : macOS Only Functions

#if os(OSX)
extension CountdownTimerView {
    override public func viewWillStartLiveResize() {
        clearAnimations()
        textLayer.isHidden = true
    }
    
    override public func viewDidEndLiveResize() {
        textLayer.isHidden = false
        animate()
    }
}
#endif

extension CountdownTimerView: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag == true {
            self.delegate?.timerDidEnd()
            self.updateTimer()
        }
    }
}
