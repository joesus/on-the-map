//
//  ViewController.swift
//  On the Map
//
//  Created by Joe Susnick on 9/6/15.
//  Copyright (c) 2015 Joe. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UIWebViewDelegate, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    let loginView : FBSDKLoginButton = FBSDKLoginButton()

    var backgroundGradient: CAGradientLayer? = nil
    var tapRecognizer: UITapGestureRecognizer? = nil
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.delegate = self
        passwordField.delegate = self
        
        self.configureUI()
        self.configureFacebook()
        self.addKeyboardDismissRecognizer()
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if isLoggedIn() { self.completeLogin() }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.removeKeyboardDismissRecognizer()
        self.unsubscribeToKeyboardNotifications()
    }
    
    // MARK: - Keyboard Fixes
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            self.view.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if keyboardAdjusted == true {
            self.view.superview?.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    // MARK: - TextField Delegate Methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.usernameField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            touchLogin(self.loginButton)
        }
        return true
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        println("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                self.completeLogin()
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("User Logged Out")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            self.completeLogin()
        }
        self.addKeyboardDismissRecognizer()
        
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.configureUI()  
    }
    
    // MARK: - Session and Login Methods
    @IBAction func touchLogin(sender: UIButton) {
        LoginClient.sharedInstance().authenticateWithViewController(self) { (success, errorString) in
            if success {
                self.completeLogin()
            } else {
                self.displayError(errorString)
            }
        }
    }
    
    @IBAction func touchSignup(sender: UIButton) {
        LoginClient.sharedInstance().signup(self) { (success, errorString) in
            if success {
                self.completeLogin()
            } else {
                self.displayError(errorString)
            }
        }
    }
    
    @IBAction func signInWithFacebook(sender: UIButton) {
        self.loginView.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
    }

    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.usernameField.text = ""
            self.passwordField.text = ""
            self.performSegueWithIdentifier("showTabBarController", sender: self)
        })
    }
    
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let errorString = errorString {
                println(errorString)
            }
        })
    }
}


extension LoginViewController {
    
    func configureUI() {
        
        /* Configure background gradient */
        self.view.backgroundColor = UIColor.clearColor()
        let colorTop = UIColor(red: 237/255, green: 123/255, blue: 38/255, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 231/255, green: 64/255, blue: 37/255, alpha: 1.0).CGColor
        self.backgroundGradient = CAGradientLayer()
        self.backgroundGradient!.colors = [colorTop, colorBottom]
        self.backgroundGradient!.locations = [0.0, 1.0]
        self.backgroundGradient!.frame = view.frame
        self.view.layer.insertSublayer(self.backgroundGradient, atIndex: 0)
        
        /* Configure header text label */
        headerLabel.font = UIFont(name: "AvenirNext-Medium", size: 24.0)
        headerLabel.textColor = UIColor.whiteColor()
        
        /* Configure email textfield */
        let emailTextFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0);
        let emailTextFieldPaddingView = UIView(frame: emailTextFieldPaddingViewFrame)
        usernameField.leftView = emailTextFieldPaddingView
        usernameField.leftViewMode = .Always
        usernameField.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
        usernameField.textColor = UIColor(red: 230/255, green: 46/255, blue: 37/255, alpha: 1.0)
        usernameField.attributedPlaceholder = NSAttributedString(string: usernameField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        usernameField.tintColor = UIColor(red: 230/255, green: 46/255, blue: 37/255, alpha: 1.0)

        /* Configure password textfield */
        let passwordTextFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0);
        let passwordTextFieldPaddingView = UIView(frame: passwordTextFieldPaddingViewFrame)
        passwordField.leftView = passwordTextFieldPaddingView
        passwordField.leftViewMode = .Always
        passwordField.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
        passwordField.textColor = UIColor(red: 230/255, green: 46/255, blue: 37/255, alpha: 1.0)
        passwordField.attributedPlaceholder = NSAttributedString(string:         passwordField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        passwordField.tintColor = UIColor(red: 230/255, green: 46/255, blue: 37/255, alpha: 1.0)
        
        /* Configure tap recognizer */
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
    }
    
    func isLoggedIn() -> Bool {
        FBSDKSettings.setAppID("365362206864879")
        return FBSDKAccessToken.currentAccessToken() != nil
    }
    
    func configureFacebook() {
        self.view.addSubview(loginView)
        self.loginView.frame.origin.x = -3000
        self.loginView.readPermissions = ["public_profile", "email", "user_friends"]
        self.loginView.delegate = self
    }
}