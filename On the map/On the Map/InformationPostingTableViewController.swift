//
//  InformationPostingTableViewController.swift
//  On the Map
//
//  Created by A658308 on 9/24/15.
//  Copyright (c) 2015 Joe. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingTableViewController: UITableViewController {

    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var urlTextView: UITextView!
    @IBOutlet weak var locationPromptLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // starts out with textview hidden
        self.urlTextView.hidden = true
    }
}
