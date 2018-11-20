//
//  LoginViewController.swift
//  WatchDog
//
//  Created by 姚逸晨 on 23/10/18.
//  Copyright © 2018 YICHEN YAO. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import NVActivityIndicatorView

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIImageView!
    @IBOutlet weak var signupButton: UIImageView!
    @IBOutlet weak var viewPassword: UIImageView!
    
    var ref: DatabaseReference?
    var handle: DatabaseHandle?
    var activityIndicator: NVActivityIndicatorView!
    var iconClick = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginTap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.loginTapDetected))
        let signupTap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.signupTapDetected))
        let viewPasswordTap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.viewPasswordTapDetected))
        
        loginButton.isUserInteractionEnabled = true
        signupButton.isUserInteractionEnabled = true
        viewPassword.isUserInteractionEnabled = true
        viewPassword.addGestureRecognizer(viewPasswordTap)
        loginButton.addGestureRecognizer(loginTap)
        signupButton.addGestureRecognizer(signupTap)
        
        
        //create firbase database reference
        ref = Database.database().reference()
        
        // manage indicator
        let indicatorSize: CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width-indicatorSize)/2, y: (view.frame.height-indicatorSize)/2, width: indicatorSize, height: indicatorSize)
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame, type: .lineScale, color: UIColor.white, padding: 20.0)
        activityIndicator.backgroundColor = UIColor.black
        view.addSubview(activityIndicator)
    }
    
    // user login function
    @objc func loginTapDetected() {
        activityIndicator.startAnimating()
        if validation(){
            readFirebase()
        }
        else {
            activityIndicator.stopAnimating()
        }
    }
    
    // user sign up function
    @objc func signupTapDetected() {
        performSegue(withIdentifier: "signup", sender: "")
    }
    
    // user view the hidden password function
    @objc func viewPasswordTapDetected() {
        if iconClick == true {
            self.passwordTextField.isSecureTextEntry = false
        }
        else {
            self.passwordTextField.isSecureTextEntry = true
        }
        
        iconClick = !iconClick
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // overall login validation
    func validation() -> Bool {
        var validation = false
        
        if emailTextField.text == "" {
            let alert = UIAlertController(title: "Sorry...", message: "Please enter an email address!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if passwordTextField.text == "" {
            let alert = UIAlertController(title: "Sorry...", message: "Please enter a password!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if !isValidEmail(testStr: emailTextField.text!) {
            let alert = UIAlertController(title: "Sorry...", message: "Please enter an invalid email address!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            validation = true
        }
        return validation
    }
    
    // email address regular expression
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    
    // attempt to signin in firebase authentication
    func readFirebase(){
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                self.activityIndicator.stopAnimating()
                
                let alert = UIAlertController(title: "Sorry...", message: "Wrong email address or password!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                self.activityIndicator.stopAnimating()
                self.performSegue(withIdentifier: "login", sender: "")
            }
        }
    }
    
    

}
