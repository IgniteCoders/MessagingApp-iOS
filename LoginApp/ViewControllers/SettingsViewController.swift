//
//  SettingsViewController.swift
//  LoginApp
//
//  Created by Mañanas on 25/4/24.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func logOutButton(_ sender: UIButton) {
        try? Auth.auth().signOut()
        
        SessionManager.isLoggedIn(false)
        
        self.navigationController?.navigationController?.popToRootViewController(animated: true)
    }

}
