//
//  MyAccountViewController.swift
//  WatchDog
//
//  Created by 姚逸晨 on 30/10/18.
//  Copyright © 2018 YICHEN YAO. All rights reserved.
//

import UIKit
import Firebase

class MyAccountViewController: UIViewController {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var logout: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var manageAccount: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var mobile: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var name: UILabel!
    
    var user = Auth.auth().currentUser
    var ref: DatabaseReference!
    var imagePicker: UIImagePickerController!
    var imageTag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        self.usernameLabel.text = user?.email
        //self.userImage = self.resizeImage(userImage)
        
        self.readUserInfo()
        self.readUserImage()
        
        let userImageTap = UITapGestureRecognizer(target: self, action: #selector(MyAccountViewController.openImageLibraryTapDetected))
        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(MyAccountViewController.openBackgroundImageLibraryTapDetected))
        let logoutTap = UITapGestureRecognizer(target: self, action: #selector(MyAccountViewController.logoutTapDetected))
        let manageAccountTap = UITapGestureRecognizer(target: self, action: #selector(MyAccountViewController.manageAccountTapDetected))
        
        logout.isUserInteractionEnabled = true
        manageAccount.isUserInteractionEnabled = true
        userImage.isUserInteractionEnabled = true
        backgroundImage.isUserInteractionEnabled = true
        logout.addGestureRecognizer(logoutTap)
        manageAccount.addGestureRecognizer(manageAccountTap)
        userImage.addGestureRecognizer(userImageTap)
        backgroundImage.addGestureRecognizer(backgroundTap)
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.userImage = self.resizeImage(userImage)
    }
    
    // user logout function
    @objc func logoutTapDetected() {
        performSegue(withIdentifier: "logout", sender: "")
    }
    
    // user change information function
    @objc func manageAccountTapDetected() {
        performSegue(withIdentifier: "manage", sender: "")
    }
    
    // user open image library for user image
    @objc func openImageLibraryTapDetected() {
        self.imageTag = 1
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // user open image library for background image
    @objc func openBackgroundImageLibraryTapDetected() {
        self.imageTag = 2
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // upload user image to firebase storage
    func uploadUserImage(_ imageView: UIImageView, type: String) {
        let storage = Storage.storage()
        var data = Data()
        data = imageView.image!.pngData()!
        
        let storageRef = storage.reference()
        let imageRef = storageRef.child("image/\(user!.uid)/\(type)")
        _ = imageRef.putData(data, metadata: nil) {(metadata, error) in
            if metadata != nil {} else {
            }
        }
    }
    
    // read user image from firebase storage
    func readUserImage() {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let userProfileImageRef = storageRef.child("image/\(user!.uid)/userProfileImage")
        let userBackgroundImageRef = storageRef.child("image/\(user!.uid)/userBackgroundImage")
        
        userProfileImageRef.getData(maxSize: 1 * 1024 * 1024, completion: {(data, error) -> Void in
            if data != nil {
                let pic = UIImage(data: data!)
                self.userImage.image = pic
            }
        })
        
        userBackgroundImageRef.getData(maxSize: 1 * 1024 * 1024, completion: {(data, error) -> Void in
            if data != nil {
                let pic = UIImage(data: data!)
                self.backgroundImage.image = pic
            }
        })
    }
    
    // read user information from firebase database
    func readUserInfo() {
        let userID = user?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let name = value?["name"] as? String ?? "Null"
            let location = value?["location"] as? String ?? "Null"
            let mobile = value?["mobile"] as? String ?? "Null"
            
            self.name.text = name
            self.location.text = location
            self.mobile.text = mobile
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }

}

// implement image library configuration
extension MyAccountViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            if self.imageTag == 1 {
                self.userImage.image = pickedImage
                self.uploadUserImage(self.userImage, type: "userProfileImage")
                
                let alert = UIAlertController(title: "Success", message: "Image uploaded!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            if self.imageTag == 2 {
                self.backgroundImage.image = pickedImage
                self.uploadUserImage(self.backgroundImage, type: "userBackgroundImage")
                
                let alert = UIAlertController(title: "Success", message: "Image uploaded!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func resizeImage(_ image: UIImageView) -> UIImageView {
        image.layer.cornerRadius = image.frame.size.width / 2
        image.clipsToBounds = true
        return image
    }
}
