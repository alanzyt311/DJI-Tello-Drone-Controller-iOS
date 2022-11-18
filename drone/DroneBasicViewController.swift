//
//  ViewController.swift
//  drone
//
//  Created by 周煜涛 on 2019/6/24.
//  Copyright © 2019 cuhksz. All rights reserved.
//

import UIKit

class DroneBasicViewController: UIViewController {
    
    private var mgr = DroneManager()
    

    @IBOutlet weak var statusHeight: UILabel!
    @IBOutlet weak var statusTime: UILabel!
    @IBOutlet weak var statusDrone: UILabel!
    @IBOutlet weak var statusConnection: UILabel!
    @IBOutlet weak var statusAlive: UILabel!
    @IBOutlet weak var batteryLevel: UIProgressView!
    @IBOutlet weak var modeControl: UISegmentedControl!
    
    @IBOutlet weak var buttonUp: UIButton!
    @IBOutlet weak var buttonRight: UIButton!
    @IBOutlet weak var buttonLeft: UIButton!
    @IBOutlet weak var buttonDown: UIButton!
    
    @IBOutlet weak var motionSlider: UISlider!
    @IBOutlet weak var motionValue: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        var drone = Global.createDrone()
        drone.delegate = self
        mgr.drone = drone
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

// Private functions
extension DroneBasicViewController {
    
    private func resetStatus() {
        Global.updateProgress(self.batteryLevel, withValue: "0")
        Global.updateLabel(self.statusAlive, withValue: "??")
        Global.updateLabel(self.statusDrone, withValue: "??")
        Global.updateLabel(self.statusConnection, withValue: "??")
        Global.updateLabel(self.statusTime, withValue: "0")
        Global.updateLabel(self.statusHeight, withValue: "0")
    }
    
    private func processStateData(withItems items: [Substring]) {
        if let value = Global.extractInfo(byKey: "bat", withItems: items) {
            Global.updateProgress(self.batteryLevel, withValue: value)
        }
        if let value = Global.extractInfo(byKey: "h", withItems: items) {
            Global.updateLabel(self.statusHeight, withValue: value)
        }
        if let value = Global.extractInfo(byKey: "t", withItems: items) {
            Global.updateLabel(self.statusTime, withValue: value)
        }
        
    }
}

// IBAction
extension DroneBasicViewController {
    
    @IBAction func motionValue(_ sender: UISlider) {
        let value = Int(sender.value)
        Global.updateLabel(self.motionValue, withValue: String(value))
    }
    
    
    // ?? TODO: set the value to min(max,current value)
    @IBAction func modeOperation(_ sender: UISegmentedControl) {
        print(#function, sender.selectedSegmentIndex)
        let mode = MotionMode(sender.selectedSegmentIndex)
        
        if mode == .rotation {
//            buttonUp.setTitle("Up", for: .normal)
//            buttonDown.setTitle("Down", for: .normal)
            buttonUp.setImage(UIImage(named: "up-circle.png"), for: .normal)
            buttonDown.setImage(UIImage(named: "down-circle.png"), for: .normal)
            buttonLeft.setImage(UIImage(named: "undo.png"), for: .normal)
            buttonRight.setImage(UIImage(named: "redo.png"), for: .normal)
            motionSlider.maximumValue = 360
        } else {
//            buttonUp.setTitle("Forward", for: .normal)
//            buttonDown.setTitle("Back", for: .normal)
//            buttonLeft.setTitle("Left", for: .normal)
//            buttonRight.setTitle("Right", for: .normal)
            buttonUp.setImage(UIImage(named: "up-circle.png"), for: .normal)
            buttonDown.setImage(UIImage(named: "down-circle.png"), for: .normal)
            buttonLeft.setImage(UIImage(named: "left-circle.png"), for: .normal)
            buttonRight.setImage(UIImage(named: "right-circle.png"), for: .normal)
            motionSlider.maximumValue = 300
        }
    }
    
    @IBAction func buttonMotion(_ sender: UIButton) {
        Global.animateButton(sender)
        
        let button = MotionButton(sender.tag)
        let value = motionValue.text ?? "20"
        let mode =  MotionMode(self.modeControl.selectedSegmentIndex)
        
        switch mode {
        case .horizontal:
            let dir = MoveDirection(sender.tag)
            self.mgr.move(inDirection: dir, withDistance: value)
        case .rotation:
            switch button {
            case .left, .right:
                let dir = RotateDirection(sender.tag)
                self.mgr.rotate(inDirection: dir, withDegree: value)
            default:
                let dir = MoveDirection(sender.tag+2)
                self.mgr.move(inDirection: dir, withDistance: value)
            }
        case .flip:
            let dir = FlipDirection(sender.tag)
            self.mgr.flip(inDirection: dir)
        }
        
    }
    
    // Combine takeoff, landing, start & stop buttons
    @IBAction func buttonMaster(_ sender: UIButton) {
        
        Global.animateButton(sender)
        let button = MotionButton(sender.tag)
        
        switch button {
        case .takeoff:
            self.mgr.takeoff()
        case .landing:
            self.mgr.landing()
        case .start:
            resetStatus()
            self.mgr.start()
        case .stop:
            resetStatus()
            self.mgr.stop()
        default:
            print("idk")
        }
        
    }
    
}

extension DroneBasicViewController: DroneDelegate {
    
    
    // state string from device
    func onStatusDataArrival(withItems items: [Substring]) {
        print(#function, items)
        self.processStateData(withItems: items)
        Global.updateLabel(self.statusAlive, withValue: "Ok")
    }
    
    func onConnectionStatusUpdate(msg: String) {
        print(#function, msg)
        Global.updateLabel(self.statusConnection, withValue: msg)
    }
    
    func onListenerStatusUpdate(msg: String) {
        print("later")
    }
    
    func onDroneStatusUpdate(msg: String) {
        print(#function, msg)
        Global.updateLabel(self.statusDrone, withValue: msg)
    }
    
    func droneIsIdling() {
        print(#function)
        Global.updateLabel(self.statusDrone, withValue: "Idle")
    }
    
    
}


