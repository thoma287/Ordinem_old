//
//  CountingLabel.swift
//  Pods
//
//  Created by Drew Thomas on 2/23/17.
//
//

import Foundation
import UIKit

class CountingLabel : UILabel{
    
    
    let counterVelocity: Float = 3.0
    
    enum CounterAnimationType{
        case Linear
        case EaseIn
        case EaseOut
    }
    
    enum CounterType{
        case Int
        case Float
    }
    
    var startNumber:Float = 0.0
    var endNumber:Float = 0.0
    
    
    var currentCounterValue:Float{
        if progress >= duration{
            return endNumber
            
        }
        let percentage = Float(progress/duration)
        let update = updateCounter(counterValue: percentage)

        return startNumber + (update * (endNumber - startNumber))
        
    }
    
    var progress:TimeInterval!
    var duration:TimeInterval!
    var lastUpdate:TimeInterval!
    
    var timer:Timer?
    
    var counterType:CounterType!
    var counterAnimationType:CounterAnimationType!
    
    func count(fromValue:Float, toValue:Float, withDuration duration:TimeInterval, andAnimationType animationType:CounterAnimationType, andCounterType counterType: CounterType){
        
        self.startNumber = fromValue
        self.endNumber = toValue
        self.duration = duration
        
        self.counterType = counterType
        self.counterAnimationType = animationType
        self.progress = 0
        self.lastUpdate = Date.timeIntervalSinceReferenceDate
        
        invalidateTimer()
        
        if duration == 0{
            updateText(value: toValue)
            return
        }
        
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(CountingLabel.updateValue), userInfo: nil, repeats: true)
        
    }
    
    func updateText(value:Float){
        
        switch counterType! {
        case .Int:
            self.text = "\(Int(value))"
        case .Float:
            self.text = String(format: "%.2f", value)
        }
        
    }
    
    
    func updateCounter(counterValue:Float) -> (Float){
        switch counterAnimationType!{
        case .Linear:
            return counterValue
        case .EaseIn:
            return powf(counterValue, counterVelocity)
        case .EaseOut:
            return 1.0 - powf(1.0 - counterValue, counterVelocity)
        }
    }
    
    
    func updateValue(){
        let now = Date.timeIntervalSinceReferenceDate
        progress = progress + (now - lastUpdate)
        lastUpdate = now
        
        if progress >= duration{
            invalidateTimer()
            progress = duration
        }
        
        updateText(value: currentCounterValue)
        
    }
    
    func invalidateTimer(){
        timer?.invalidate()
        timer = nil
        
    }

    
}
