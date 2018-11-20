//
//  SignupViewController.swift
//  WatchDog
//
//  Created by 姚逸晨 on 23/10/18.
//  Copyright © 2018 YICHEN YAO. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class SignupViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmedPassword: UITextField!
    @IBOutlet weak var hasAccount: UIImageView!
    @IBOutlet weak var signupButton: UIImageView!
    @IBOutlet weak var viewPassword: UIImageView!
    
    var ref: DatabaseReference?
    var handle: DatabaseHandle?
    var iconClick = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let hasAccountTap = UITapGestureRecognizer(target: self, action: #selector(SignupViewController.hasAccountTapDetected))
        let signupTap = UITapGestureRecognizer(target: self, action: #selector(SignupViewController.signupTapDetected))
        let viewPasswordTap = UITapGestureRecognizer(target: self, action: #selector(SignupViewController.viewPasswordTapDetected))
        
        hasAccount.isUserInteractionEnabled = true
        signupButton.isUserInteractionEnabled = true
        viewPassword.isUserInteractionEnabled = true
        hasAccount.addGestureRecognizer(hasAccountTap)
        signupButton.addGestureRecognizer(signupTap)
        viewPassword.addGestureRecognizer(viewPasswordTap)
        
        //create firbase database reference
        ref = Database.database().reference()
    }
    
    // jump back to login function
    @objc func hasAccountTapDetected() {
        performSegue(withIdentifier: "hasAccount", sender: "")
    }
    
    // user sign up function
    @objc func signupTapDetected() {
        if validation() {
            postFirebase()
        }
    }
    
    // user can view hidden password
    @objc func viewPasswordTapDetected() {
        if iconClick == true {
            self.passwordTextField.isSecureTextEntry = false
            self.confirmedPassword.isSecureTextEntry = false
        }
        else {
            self.passwordTextField.isSecureTextEntry = true
            self.confirmedPassword.isSecureTextEntry = true
        }
        
        iconClick = !iconClick
    }
    
    // overall sign up validation
    func validation() -> Bool {
        var validation = false
        
        if emailTextField.text == "" {
            let alert = UIAlertController(title: "Sorry...", message: "Please enter an email address.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .`default`, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if passwordTextField.text == "" {
            let alert = UIAlertController(title: "Sorry...", message: "Please enter a password.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .`default`, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if confirmedPassword.text == "" {
            let alert = UIAlertController(title: "Sorry...", message: "Please enter a confirmed password.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .`default`, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if confirmedPassword.text != passwordTextField.text {
            let alert = UIAlertController(title: "Sorry...", message: "Confirmed password must be the same as the password.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .`default`, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if !isValidEmail(testStr: emailTextField.text!) {
            let alert = UIAlertController(title: "Sorry...", message: "Please enter an valid Email address.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .`default`, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            validation = true
        }
        return validation
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // email address regular expression
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    
    // attempt to create user in firebase authentication
    func postFirebase() {
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                let alert = UIAlertController(title: "Sorry...", message: "Email address already exists!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else{
                self.performSegue(withIdentifier: "signupok", sender: "")
            }
        }
    }

}
