//
//  DroneDualControlViewController.swift
//  drone
//
//  Created by 周煜涛 on 2019/7/9.
//  Copyright © 2019 cuhksz. All rights reserved.
//

import UIKit
import CoreMotion
import AudioToolbox

class DroneDualControlViewController: UIViewController {
    

    
    @IBOutlet weak var controllerLeft: JoyStickView!
    @IBOutlet weak var controllerRight: JoyStickView!
    
    private var mgr = DroneManager()
    
    private var motionManager: CMMotionManager?
    private var tilted: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var drone = Global.createDrone()
        drone.delegate = self
        mgr.drone = drone
        
        controllerLeft.ID = .left
        controllerRight.ID = .right
        
        controllerLeft.delegate = self
        controllerRight.delegate = self
        
        // Do any additional setup after loading the view.
        self.motionManager = CMMotionManager()
        
        if let manager = self.motionManager {
            
            if manager.isDeviceMotionAvailable {
                manager.deviceMotionUpdateInterval = TimeInterval(1)
                manager.startDeviceMotionUpdates(to: .main, withHandler: deviceMotionHandler(data:error:))
            }
            
        }
    }
    
}

// Motion Sensor handler
extension DroneDualControlViewController {
    


    @IBAction func buttonMaster(_ sender: UIButton) {
        
        Global.animateButton(sender)
        let button = MotionButton(sender.tag)
        
        switch button {
        case .takeoff:
            self.mgr.takeoff()
        case .landing:
            self.mgr.landing()
        case .start:
//            resetStatus()
            self.mgr.start()
//            print("start")
        case .stop:
//            resetStatus()
            self.mgr.stop()
//            print("stop")
        default:
            print("idk")
        }
        
    }
    
    
    func deviceMotionHandler(data: CMDeviceMotion?, error: Error? ) {
        
        guard let data = data, error == nil else { return }
        //        print(#function, data.gravity)
        
        // For landscape use gravity.x, for portrait use gravity.y
        let t = abs(data.gravity.x) > 0.6
        
        // Play an alert
        if t != self.tilted {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.tilted = t
        }
        
    }
    
}

extension DroneDualControlViewController: JoystickMotionDelegate {
    
    func joystickMotion(pos: ControllerPosition, dir: JoystickDirection, touches: Int, value: Int) {
        print(#function, pos, dir, touches, value)
        
        switch pos {
        case .left:
            switch dir {
            case .left:
                self.mgr.move(inDirection: .left, withDistance: String(value))
            case .right:
                self.mgr.move(inDirection: .right, withDistance: String(value))
            case .up:
                self.mgr.move(inDirection: .forward, withDistance: String(value))
            case .down:
                self.mgr.move(inDirection: .back, withDistance: String(value))
            case .cw:
                self.mgr.rotate(inDirection: RotateDirection(1) ,withDegree: String(value))
            case .ccw:
                self.mgr.rotate(inDirection: RotateDirection(0) ,withDegree: String(value))
            default:
                break
            }
        case .right:
            switch dir {
            case .left:
                self.mgr.flip(inDirection: .left)
            case.right:
                self.mgr.flip(inDirection: .right)
            case .up:
                self.mgr.move(inDirection: .up, withDistance: String(value))
            case .down:
                self.mgr.move(inDirection: .down, withDistance: String(value))
            case .cw:
                self.mgr.rotate(inDirection: RotateDirection(1) ,withDegree: String(value))
            case .ccw:
                self.mgr.rotate(inDirection: RotateDirection(0) ,withDegree: String(value))


            default:
                break
            }
        }
    }
    
}

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */



extension DroneDualControlViewController: DroneDelegate {
    func onStatusDataArrival(withItems items: [Substring]) {
        print(#function)
    }
    
    func onConnectionStatusUpdate(msg: String) {
        print(#function)

    }
    
    func onListenerStatusUpdate(msg: String) {
        print(#function)

    }
    
    func onDroneStatusUpdate(msg: String) {
        print(#function)

    }
    
    func droneIsIdling() {
        print(#function)

    }
    
    
}
