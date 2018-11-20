//
//  HomeViewController.swift
//  WatchDog
//
//  Created by 姚逸晨 on 30/10/18.
//  Copyright © 2018 YICHEN YAO. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import Firebase

class HomeViewController: UIViewController{


    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var welcomeLabel: UILabel?
    @IBOutlet weak var locationLabel: UILabel?
    @IBOutlet weak var dayLabel: UILabel?
    @IBOutlet weak var conditionImageView: UIImageView?
    @IBOutlet weak var conditionLabel: UILabel?
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var indoorTempLabel: UILabel!
    @IBOutlet weak var indoorTempTimeLabel: UILabel!
    
    
    var user = Auth.auth().currentUser
    var ref: DatabaseReference!
    
    var lat: String = "-37.876823"
    var lon: String = "145.045837"
    var name: String = "tommy"
    var indoorTemp: Double = 20.0
    var indoorTempTime: String = "2018:10:31:20:00:00"
    
    let gradientLayer = CAGradientLayer()
    
    let apiKey = "2853b2b3bc4b5184a092478662ddb17b"
    var activityIndicator: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        backgroundView?.layer.addSublayer(gradientLayer)
        
        // manage indicator 
        let indicatorSize: CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width-indicatorSize)/2, y: (view.frame.height-indicatorSize)/2, width: indicatorSize, height: indicatorSize)
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame, type: .lineScale, color: UIColor.white, padding: 20.0)
        activityIndicator.backgroundColor = UIColor.black
        view.addSubview(activityIndicator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setBlueGradientBackground()
        activityIndicator.startAnimating()
        
        DispatchQueue.main.async {
            self.readUserInfo()
        }
    }
    
    // Open weather API to get the weather condition from the coordinate of user address and update labels
    func weather() {
        
        Alamofire.request("http://api.openweathermap.org/data/2.5/weather?lat=\(self.lat)&lon=\(self.lon)&appid=\(apiKey)&units=metric").responseJSON {
            response in
            
            if let responseStr = response.result.value {
                let jsonResponse = JSON(responseStr)
                let jsonWeather = jsonResponse["weather"].array![0]
                let jsonTemp = jsonResponse["main"]
                let iconName = jsonWeather["icon"].stringValue
                
                self.locationLabel?.text = jsonResponse["name"].stringValue
                self.conditionImageView?.image = UIImage(named: iconName)
                self.conditionLabel?.text = jsonWeather["main"].stringValue
                self.temperatureLabel?.text = "\(Int(round(jsonTemp["temp"].doubleValue)))"
                self.welcomeLabel?.text = "Welcome \(self.name)!"
                
                self.indoorTempLabel.text = "\(Int(round(self.indoorTemp)))"
                self.indoorTempTimeLabel.text = self.indoorTempTime
                
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE"
                self.dayLabel?.text = dateFormatter.string(from: date)
                
                let suffix = iconName.suffix(1)
                if(suffix == "n"){
                    self.setGreyGradientBackground()
                }else{
                    self.setBlueGradientBackground()
                }
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    // set the blue gradient background
    func setBlueGradientBackground(){
        let topColor = UIColor(red: 95.0/255.0, green: 165.0/255.0, blue: 1.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 72.0/255.0, green: 114.0/255.0, blue: 184.0/255.0, alpha: 1.0).cgColor
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, bottomColor]
    }
    
    // set the grey gradient background
    func setGreyGradientBackground(){
        let topColor = UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 72.0/255.0, green: 72.0/255.0, blue: 72.0/255.0, alpha: 1.0).cgColor
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, bottomColor]
    }
    
    // read user information from firebase database
    func readUserInfo() {
        let userID = user?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.lat = value?["lat"] as? String ?? "-37.876823"
            self.lon = value?["lon"] as? String ?? "145.045837"
            self.name = value?["name"] as? String ?? ""
            
            DispatchQueue.main.async {
                self.readTemperature()
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    // read the last child's value of temperature in firebase database
    func readTemperature() {
        
        ref.child("temperature").queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) in
            
            // Get the last temperature value
            let value = snapshot.value as? NSDictionary

            self.indoorTemp = value?["temp"] as? Double ?? 20.0
            let tempTime = value?["time"] as? String ?? "2018:10:31:20:00:00"
            
            let timeArray = tempTime.split(separator: ":")
            let date = "\(timeArray[0])/\(timeArray[1])/\(timeArray[2])"
            let time = "\(timeArray[3]):\(timeArray[4]):\(timeArray[5])"
            
            self.indoorTempTime = "Last Updated: \(date) \(time)"
            
            DispatchQueue.main.async {
                self.weather()
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
}
