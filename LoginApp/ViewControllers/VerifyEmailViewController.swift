//
//  VerifyEmailViewController.swift
//  LoginApp
//
//  Created by Mañanas on 22/4/24.
//

import UIKit
import FirebaseAuth

class VerifyEmailViewController: UIViewController {
    
    // MARK: Properties
    
    var timer: Timer? = nil
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sendEmailButton(nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if timer != nil {
            timer?.invalidate()
        }
    }
    
    // MARK: Internal methods
    
    func emailVerified () {
        let alert = UIAlertController(title: "Verificar cuenta", message: "Cuenta verificada correctamente", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Volver al Login", style: .default, handler: { action in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(alert, animated: true)
    }
    
    // MARK: Actions
    
    @IBAction func sendEmailButton(_ sender: UIButton?) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        user.sendEmailVerification()
        
        if timer != nil {
            timer?.invalidate()
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            user.reload()
            if (user.isEmailVerified) {
                timer.invalidate()
                self.emailVerified()
            }
        }
    }
}
