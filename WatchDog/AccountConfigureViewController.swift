//
//  AccountConfigureViewController.swift
//  WatchDog
//
//  Created by 姚逸晨 on 30/10/18.
//  Copyright © 2018 YICHEN YAO. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView

class AccountConfigureViewController: UIViewController {
    
    var ref: DatabaseReference!
    var user = Auth.auth().currentUser
    var thread : DispatchQueue
    var lat_str: String = ""
    var lon_str: String = ""
    var api_key = "AIzaSyCYjoQxYT1jJF157LxyXp-AoQyR8ovLVIc"
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var mobile: UITextField!
    @IBOutlet weak var save: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        thread = DispatchQueue.global(qos: .background)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        let saveTap = UITapGestureRecognizer(target: self, action: #selector(AccountConfigureViewController.saveTapDetected))
        
        save.isUserInteractionEnabled = true
        save.addGestureRecognizer(saveTap)
    }
    
    // mobile number regular expression
    func isValidMobile(testStr:String) -> Bool {
        let mobileRegEx = "^04(\\s?[0-9]{2}\\s?)([0-9]{3}\\s?[0-9]{3}|[0-9]{2}\\s?[0-9]{2}\\s?[0-9]{2})$"
        let mobileTest = NSPredicate(format:"SELF MATCHES %@", mobileRegEx)
        let result = mobileTest.evaluate(with: testStr)
        return result
    }
    
    // save information function
    @objc func saveTapDetected() {
        if validation() {
            if saveInfo() {
                performSegue(withIdentifier: "saveinfo", sender: "")
            }
            else {
                let alert = UIAlertController(title: "Sorry...", message: "Save information failure!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    // overall user information validation
    func validation() -> Bool {
        var validation = false
        
        if name.text == "" {
            let alert = UIAlertController(title: "Sorry...", message: "Please enter a name!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if location.text == "" {
            let alert = UIAlertController(title: "Sorry...", message: "Please enter a location!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if mobile.text == "" {
            let alert = UIAlertController(title: "Sorry...", message: "Please enter a mobile number!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if !isValidMobile(testStr: mobile.text!) {
            let alert = UIAlertController(title: "Sorry...", message: "Please enter a valid mobile number!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            validation = true
        }
        return validation
    }
    
    // upload the user information to firebase
    func saveInfo() -> Bool {
        var save = false
        
        self.convertAddressToCoordinates()
        sleep(1)
        if self.lat_str != "" && self.lon_str != ""{
            self.ref.child("users/\(self.user!.uid)/name").setValue(self.name.text)
            self.ref.child("users/\(self.user!.uid)/location").setValue(self.location.text)
            self.ref.child("users/\(self.user!.uid)/mobile").setValue(self.mobile.text)
            self.ref.child("users/\(self.user!.uid)/lat").setValue(self.lat_str)
            self.ref.child("users/\(self.user!.uid)/lon").setValue(self.lon_str)
            save = true
        }
        else {
            let alert = UIAlertController(title: "Sorry...", message: "Please enter a valid address!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        return save
    }
    
    // Google geocoding API to convert address to coordinate
    func convertAddressToCoordinates(){

        let address = self.location.text?.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        let queue = DispatchQueue(label: "com.cnoon.response-queue", qos: .background, attributes: .concurrent)
        
        Alamofire.request("https://maps.googleapis.com/maps/api/geocode/json?address=\(address!)&key=\(self.api_key)").responseJSON(queue: queue, options: .allowFragments) {
            response in
            let responseStr = response.result.value
            if responseStr != nil {
                let jsonResponse = JSON(responseStr!)
                let jsonResult = jsonResponse["results"].array![0]
                let jsonGeometry = jsonResult["geometry"]
                let jsonLocation = jsonGeometry["location"]
                
                self.lat_str = jsonLocation["lat"].stringValue
                self.lon_str = jsonLocation["lng"].stringValue
            }
        }
    }

}
