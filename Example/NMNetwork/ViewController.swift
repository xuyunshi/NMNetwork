//
//  ViewController.swift
//  NMNetwork
//
//  Created by 405029644@qq.com on 09/30/2018.
//  Copyright (c) 2018 405029644@qq.com. All rights reserved.
//

import UIKit
import NMNetwork

class ViewController: UIViewController {
    
    
    @IBAction func onClickSuccess(_ sender: Any) {
        TestAPI.success.convenientrequest { (data) in
            
        }
        
    }
}

