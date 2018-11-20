//
//  CustomTabBarController.swift
//  WatchDog
//
//  Created by 姚逸晨 on 24/10/18.
//  Copyright © 2018 YICHEN YAO. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

class CustomTabBarController: UITabBarController, UNUserNotificationCenterDelegate{
    
    var thread : DispatchQueue
    var ref: DatabaseReference!
    var timer: Timer?
    
    
    required init?(coder aDecoder: NSCoder) {
        thread = DispatchQueue.global(qos: .background)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tabBarItem: UITabBarItem
        
        ref = Database.database().reference()
        
        // UITabBar configuration
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray], for: .normal)
        
        let selectedImage1 = UIImage(named: "myhome_de")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage1 = UIImage(named: "myhome")?.withRenderingMode(.alwaysOriginal)
        tabBarItem = self.tabBar.items![0]
        tabBarItem.image = deSelectedImage1
        tabBarItem.selectedImage = selectedImage1
        
        let selectedImage2 = UIImage(named: "alarm_de")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage2 = UIImage(named: "alarm")?.withRenderingMode(.alwaysOriginal)
        tabBarItem = self.tabBar.items![1]
        tabBarItem.image = deSelectedImage2
        tabBarItem.selectedImage = selectedImage2
        
        let selectedImage3 = UIImage(named: "camera_de")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage3 = UIImage(named: "camera")?.withRenderingMode(.alwaysOriginal)
        tabBarItem = self.tabBar.items![2]
        tabBarItem.image = deSelectedImage3
        tabBarItem.selectedImage = selectedImage3
        
        let selectedImage4 = UIImage(named: "about_de")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage4 = UIImage(named: "about")?.withRenderingMode(.alwaysOriginal)
        tabBarItem = self.tabBar.items![3]
        tabBarItem.image = deSelectedImage4
        tabBarItem.selectedImage = selectedImage4
        
        let selectedImage5 = UIImage(named: "myaccount_de")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage5 = UIImage(named: "myaccount")?.withRenderingMode(.alwaysOriginal)
        tabBarItem = self.tabBar.items![4]
        tabBarItem.image = deSelectedImage5
        tabBarItem.selectedImage = selectedImage5
        
        let numbersOfTabs = CGFloat((tabBar.items?.count)!)
        let tabBarSize = CGSize(width: tabBar.frame.width / numbersOfTabs, height: tabBar.frame.height)
        tabBar.selectionIndicatorImage = UIImage.imageWithColor(color: UIColor.init(red: 93/255, green: 188/255, blue: 210/255, alpha: 1), size: tabBarSize)
        
        self.selectedIndex = 0
        
        // timer to invoke alarm function every 5 seconds
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(CustomTabBarController.alarm), userInfo: nil, repeats: true)
    }
    
    // global dispatch queue to read buzzer status
    @objc func alarm() {
        DispatchQueue.global(qos: .background).async() {
            self.readBuzzerStatus()
        }
    }
    
    // read buzzer status to show alert and notification or not
    func readBuzzerStatus() {
        
        ref.child("buzzerSwitch").observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Get system status value
            let value = snapshot.value as? NSDictionary
            let buzzerStatus = value?["status"] as? String ?? "0"
            
            if buzzerStatus == "1" {
                
                print("1")
                self.notification()
                
                print("2")
                let alert = UIAlertController(title: "Emergency!!", message: "The door is open", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {action -> Void in
                    //self.thread.resume()
                }))
                
                self.present(alert, animated: true, completion: nil)
                
                //self.thread.suspend()
            }
            else {
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // the content of the notification
    func notification() {
        let content = UNMutableNotificationContent()
        content.title = "Emergency"
        content.body = "Someone breaks into your house"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "testidentifier"
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest.init(identifier: "testidentifier", content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request)
    }
    
}

// when the user press the tab bar item, the UIImage will change color
extension UIImage {
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
