//
//  WebSignupViewController.swift
//  On the Map
//
//  Created by Joe Susnick on 9/7/15.
//  Copyright (c) 2015 Joe. All rights reserved.
//

import UIKit
import Foundation

class WebSignupViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var signupWebView: UIWebView!
    var urlRequest: NSURLRequest?
    var completionHandler : ((success: Bool, errorString: String?) -> Void)? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signupWebView.delegate = self
        self.navigationItem.title = "Udacity"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelAuth")

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        if urlRequest != nil {
            self.signupWebView.loadRequest(urlRequest!)
        }
    }

    // MARK: - UIWebViewDelegate
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
        if(signupWebView.request!.URL!.absoluteString! == "https://www.udacity.com/me#!/") {
            
            let alert = UIAlertView(title: "Welcome", message: "Thanks for signing up. Go ahead and login!", delegate: self, cancelButtonTitle: nil)
            alert.show()
            
            let delay = 3 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue()) {
                alert.dismissWithClickedButtonIndex(0, animated: true)
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    self.completionHandler!(success: false, errorString: nil)
                })
            }
        }
    }
    
    func cancelAuth() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
