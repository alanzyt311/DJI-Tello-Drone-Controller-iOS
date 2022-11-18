//
//  JoystickView.swift
//  drone
//
//  Created by 周煜涛 on 2019/7/11.
//  Copyright © 2019 cuhksz. All rights reserved.
//

import UIKit

class JoyStickView: UIView {
    
    // bad design
    //    var mgr: DroneManager?
    
    var delegate: JoystickMotionDelegate?
    var ID: ControllerPosition = .left
    
    private var originalCenter: CGPoint = .zero
    private var rotatedVaue: CGFloat = 0.0
    private var touches: Int = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createGesture()
        self.layer.cornerRadius = self.bounds.width/2.0
    }
}

// Gesture
extension JoyStickView {
    
    
    private func createGesture() {
        
        let p = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        p.maximumNumberOfTouches = 2
        p.minimumNumberOfTouches = 1
        self.addGestureRecognizer(p)
        
        let r = UIRotationGestureRecognizer(target: self, action: #selector(rotate(_:)))
        self.addGestureRecognizer(r)
        
    }
    
    // Handling pan gesture (dragging)
    @objc private func pan(_ gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            self.originalCenter = self.center
            self.touches = gesture.numberOfTouches
            
        case .ended:
            let dx =  self.center.x - self.originalCenter.x
            let dy = self.center.y - self.originalCenter.y
            var dir: JoystickDirection = .center
            var value = Int(abs(dx))
            if abs(dx) > abs(dy) {
                dir = dx < 0 ? .left : .right
            } else {
                dir = dy < 0 ? .up : .down
                value = Int(abs(dy))
            }
            
            self.delegate?.joystickMotion(pos: self.ID, dir: dir, touches: self.touches, value: value)
            
            UIView.animate(withDuration: 0.2, animations: {
                self.center = self.originalCenter
            })
            
        case .changed:
            let t = gesture.translation(in: self)
            let c = CGPoint(x: self.center.x + t.x, y: self.center.y + t.y)
            self.center = c
            gesture.setTranslation(.zero, in: self)
            
        default:
            break
        }
        
    }
    
    // Handling Rotation Gesture
    @objc private func rotate(_ gesture: UIRotationGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            self.rotatedVaue = 0.0
        case .changed:
            self.rotatedVaue += gesture.rotation
            self.transform = self.transform.rotated(by: gesture.rotation)
            gesture.rotation = 0.0
        case .ended:
            let deg = abs(Int(self.rotatedVaue*180.0/CGFloat.pi))
            let dir:JoystickDirection = self.rotatedVaue > 0 ? .cw : .ccw
            self.delegate?.joystickMotion(pos: self.ID, dir: dir, touches: 2, value: deg)
            UIView.animate(withDuration: 0.2, animations: {
                self.transform = .identity
            })
        default:
            break
        }
        
    }
    
}

