//
//  AlarmViewController.swift
//  WatchDog
//
//  Created by 姚逸晨 on 2/11/18.
//  Copyright © 2018 YICHEN YAO. All rights reserved.
//

import UIKit
import Firebase

class AlarmViewController: UIViewController {

    @IBOutlet weak var `switch`: UISwitch!
    @IBAction func `switch`(_ sender: UISwitch) {
        if sender.isOn == true {
            self.startMonitoring()
            self.monitorLabel.text = "Current monitor status: On."
        }
        else {
            self.stopMonitoring()
            self.monitorLabel.text = "Current monitor status: Off."
        }
    }
    
    @IBOutlet weak var buzzerLabel: UILabel!
    @IBOutlet weak var monitorLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    let clock = Clock()
    var timer: Timer?
    var buzzerTimer: Timer?
    
    var ref: DatabaseReference!
    var systemStatus = ""
    var buzzerStatus = ""
    
    // Buzzer turn off button, set value to firebase
    @IBAction func buzzer(_ sender: Any) {
        self.buzzerLabel.text = "Current buzzer status: Off."
        let buzzer = ["status": "0"]
        ref.child("buzzerSwitch").setValue(buzzer)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // timer to update the time label
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(AlarmViewController.updateTimeLabel), userInfo: nil, repeats: true)
        
        ref = Database.database().reference()
        self.readSystemStatus()
        self.readBuzzerStatus()
        
        // timer to change the buzzer status
        buzzerTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(AlarmViewController.buzzerStatusChange), userInfo: nil, repeats: true)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ref = Database.database().reference()
        self.readSystemStatus()
        self.readBuzzerStatus()
        
        updateTimeLabel()
        buzzerStatusChange()
        
    }
    
    // update time label function
    @objc func updateTimeLabel() {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        timeLabel.text = formatter.string(from: clock.currentTime as Date)
    }
    
    // find the buzzer status change and update the buzzer label
    @objc func buzzerStatusChange() {
        let lastBuzzerStatus = self.buzzerStatus
        self.readBuzzerStatus()
        if lastBuzzerStatus == "0" && self.buzzerStatus == "1" {
            self.buzzerLabel.text = "Current buzzer status: On."
        }
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // stop monitoring status
    func stopMonitoring() {
        let status = ["status": "0"]
        ref.child("systemSwitch").setValue(status)
    }
    
    // start monitoring status
    func startMonitoring() {
        let status = ["status": "1"]
        ref.child("systemSwitch").setValue(status)
    }
    
    // read the system status from firebase database and update the system status and buzzer status label
    func readSystemStatus() {
        ref.child("systemSwitch").observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Get system status value
            let value = snapshot.value as? NSDictionary
            self.systemStatus = value?["status"] as? String ?? "0"
            
            if self.systemStatus == "0"{
                self.`switch`.setOn(false, animated: false)
                self.monitorLabel.text = "Current monitor status: Off."
                self.buzzerLabel.text = "Current buzzer status: Off."
            }
            else {
                self.`switch`.setOn(true, animated: false)
                self.monitorLabel.text = "Current monitor status: On."
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // read the buzzer status from the firebase database and update the buzzer label
    func readBuzzerStatus() {
        ref.child("buzzerSwitch").observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Get system status value
            let value = snapshot.value as? NSDictionary
            self.buzzerStatus = value?["status"] as? String ?? "0"
            
            if self.buzzerStatus == "0" {
                self.buzzerLabel.text = "Current buzzer status: Off."
                
            }
            else {
                self.buzzerLabel.text = "Current buzzer status: On."
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    deinit {
        if let timer = self.timer {
            timer.invalidate()
        }
    }

}
