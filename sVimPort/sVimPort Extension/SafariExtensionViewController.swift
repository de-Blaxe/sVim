//
//  SafariExtensionViewController.swift
//  sVimPort Extension
//
//  Created by Donald Lieu on 8/15/19.
//  Copyright © 2019 Donald Lieu. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:320, height:240)
        return shared
    }()

}
