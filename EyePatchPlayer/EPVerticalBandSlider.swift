//
//  EPVerticalBandSlider.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 03/11/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit
import QuartzCore

class EPVerticalBandSlider: UIControl {
    
    var maximumValue = 24.0
    var minimumValue = -24.0
    
    var currentValue = 0.7
    
    var bandFrequencyString = "32" {
        didSet {
            self.textLayer.string = bandFrequencyString
            self.textLayer.setNeedsDisplay()
        }
    }
    
    let trackLayer = CAShapeLayer()
    let thumbLayer = EPBandSliderThumbLayer()
    let textLayer = CATextLayer()
    var previousLocation = CGPoint()
    
    var thumbWidth: CGFloat {
        return CGFloat(round(self.bounds.width*0.85/2)*2)
    }
    
    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
    
    //MARK: init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        trackLayer.backgroundColor = UIColor.lightGrayColor().CGColor
        thumbLayer.backgroundColor = UIColor.blueColor().CGColor
        
        layer.addSublayer(trackLayer)
        layer.addSublayer(thumbLayer)
        
        thumbLayer.bandSlider = self
        
        textLayer.contentsScale = UIScreen.mainScreen().scale
        textLayer.string = "00"
        textLayer.fontSize = 12
        textLayer.alignmentMode = kCAAlignmentCenter
            
        textLayer.backgroundColor = UIColor.blueColor().CGColor
        textLayer.foregroundColor = UIColor.darkGrayColor().CGColor
        layer.addSublayer(self.textLayer)
        
        updateLayerFrames()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        trackLayer.backgroundColor = UIColor.lightGrayColor().CGColor
//        thumbLayer.fillColor = UIColor.blueColor().CGColor
        
        layer.addSublayer(trackLayer)
        layer.addSublayer(thumbLayer)
        layer.addSublayer(textLayer)
        thumbLayer.bandSlider = self
        
        textLayer.contentsScale = UIScreen.mainScreen().scale
        textLayer.string = "00"
        textLayer.fontSize = 16
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.backgroundColor = UIColor.whiteColor().CGColor
        textLayer.foregroundColor = UIColor.darkGrayColor().CGColor
        
        updateLayerFrames()
    }
    
    override func awakeFromNib() {
        self.backgroundColor = UIColor.clearColor()
    }

    //MARK: Layout
    
    func updateLayerFrames() {
        trackLayer.frame = self.bounds.insetBy(dx: round(bounds.width / 2.15), dy: 0.0)
        trackLayer.setNeedsDisplay()
        
        let thumbCenter = CGFloat(positionForValue(currentValue))
        thumbLayer.frame = CGRect(x: (bounds.width-thumbWidth)/2, y: thumbCenter - thumbWidth / 2.0,
            width: thumbWidth, height: thumbWidth)
        thumbLayer.setNeedsDisplay()
        
        textLayer.frame = CGRectMake(0,self.bounds.height-textLayer.fontSize*1.1,self.bounds.width, textLayer.fontSize*1.1)
        print(textLayer.frame)
        textLayer.setNeedsDisplay()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayerFrames()
    }
    
    func positionForValue(value: Double) -> Double {
        return Double(self.bounds.height-textLayer.fontSize*1.1) - (Double(self.bounds.height-textLayer.fontSize*1.1 - thumbWidth) * (value - minimumValue) /
            (maximumValue - minimumValue) + Double(thumbWidth / 2.0))
    }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
            previousLocation = touch.locationInView(self)
            
            // Hit test the thumb layers
            if thumbLayer.frame.contains(previousLocation) {
                thumbLayer.highlighted = true
            }
        return thumbLayer.highlighted
    }
    
    func boundValue(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)
        
        // 1. Determine by how much the user has dragged
        let deltaLocation = -Double(location.y - previousLocation.y)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.height - thumbWidth)
        
        previousLocation = location
        
        // 2. Update the values
        if thumbLayer.highlighted {
            currentValue += deltaValue
            currentValue = boundValue(currentValue, toLowerValue: minimumValue, upperValue: maximumValue)
        }
        
        // 3. Update the UI
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        updateLayerFrames()
        
        CATransaction.commit()
        sendActionsForControlEvents(.ValueChanged)
        return true
    }

    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        sendActionsForControlEvents(.EditingDidEnd)
        thumbLayer.highlighted = false
    }

    func setValue(value:Double, animated: Bool) {
        if animated {
            self.currentValue = value
            UIView.animateWithDuration(0.3, animations: { () -> Void in
//                self.setNeedsDisplay()
                self.updateLayerFrames()
            })
        } else {
            self.currentValue = value
        }
    }
}
