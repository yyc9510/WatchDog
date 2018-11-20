//
//  GalleryViewController.swift
//  WatchDog
//
//  Created by 姚逸晨 on 2/11/18.
//  Copyright © 2018 YICHEN YAO. All rights reserved.
//

import UIKit
import Firebase
import AVKit
import AVFoundation
import NVActivityIndicatorView

class GalleryViewController: UIViewController {

    @IBOutlet weak var videoView: VideoView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var alarmTimeLabel: UILabel!
    var ref: DatabaseReference!
    var alarmTime: String = ""
    var url: URL = URL(fileURLWithPath: "")
    var imageTimer: Timer?
    var activityIndicator: NVActivityIndicatorView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        // manage indicator
        let indicatorSize: CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width-indicatorSize)/2, y: (view.frame.height-indicatorSize)/2, width: indicatorSize, height: indicatorSize)
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame, type: .lineScale, color: UIColor.white, padding: 20.0)
        activityIndicator.backgroundColor = UIColor.black
        view.addSubview(activityIndicator)
        
        // add a imageTimer to change the image based on the alarm status
        imageTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(GalleryViewController.alarmStatusChange), userInfo: nil, repeats: true)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        activityIndicator.startAnimating()
        DispatchQueue.main.async {
            self.readAlarmTime()
        }
        alarmStatusChange()
    }
    
    @objc func alarmStatusChange() {
        let lastAlarmTime = self.alarmTime
        self.readAlarmTime()
        if lastAlarmTime != self.alarmTime {
            DispatchQueue.main.async {
                self.readAlarmTime()
            }
        }
    }
    
    // read image from firebase storage
    func readImage() {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let image = storageRef.child("cameraImage/\(self.alarmTime).jpg")
        
        image.getData(maxSize: 1 * 1024 * 1024, completion: {(data, error) -> Void in
            if data != nil {
                let pic = UIImage(data: data!)
                self.image.image = pic
            }
        })
        
    }
    
    // read video from firebase storage
    func readVideo() {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let video = storageRef.child("cameraVideo/\(self.alarmTime).mp4")
        
        video.downloadURL(completion: {(url, error) -> Void in
            if url != nil {
                self.url = url!
                self.videoView.configure(url: url!)
                self.videoView.isLoop = true
                self.videoView.play()
                self.activityIndicator.stopAnimating()
            }
        })
    }
    
    // read alarm time and status data from the firebase database
    func readAlarmTime() {
        ref.child("alarmTime").observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Get system status value
            let value = snapshot.value as? NSDictionary
            self.alarmTime = value?["time"] as? String ?? "00:00:00"
            
            self.alarmTimeLabel.text = "Last alarm time is: \(self.alarmTime)"
            
            DispatchQueue.main.async {
                self.readImage()
            }
            DispatchQueue.main.async {
                self.readVideo()
            }
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
