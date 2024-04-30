//
//  SignUpViewController.swift
//  LoginApp
//
//  Created by Mañanas on 19/4/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var genderImageView: UIImageView!
    @IBOutlet weak var birthdayDatePicker: UIDatePicker!
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: Actions
    
    @IBAction func genderSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            genderImageView.image = UIImage(named: "genderIcon-male")
        case 1:
            genderImageView.image = UIImage(named: "genderIcon-female")
        default:
            genderImageView.image = UIImage(named: "genderIcon-other")
        }
    }
    
    @IBAction func signUpButton(_ sender: UIButton) {
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        
        if validateData() {
            Auth.auth().createUser(withEmail: username, password: password) { authResult, error in
              // ...
                if (error == nil) {
                    // Correcto
                    self.createUser()
                } else {
                    print(error!.localizedDescription)
                }
            }
        }
    }
    
    func createUser() {
        let userID = Auth.auth().currentUser!.uid
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        let firstName = firstNameTextField.text!
        let lastName = lastNameTextField.text!
        let birthday = birthdayDatePicker.date
        let gender = switch genderSegmentedControl.selectedSegmentIndex {
        case 0:
            Gender.male
        case 1:
            Gender.female
        default:
            Gender.other
        }
        
        let db = Firestore.firestore()
        
        let user = User(id: userID, username: username, firstName: firstName, lastName: lastName, gender: gender, birthday: birthday, provider: .basic, profileImageUrl: nil)
        
        do {
            try db.collection("Users").document(userID).setData(from: user)
            
            self.performSegue(withIdentifier: "navigateToEmailVerification", sender: self)
        } catch let error {
            print("Error writing user to Firestore: \(error)")
        }
    }
    
    func validateData() -> Bool {
        if firstNameTextField.text?.isEmpty ?? true {
            return false
        }
        if lastNameTextField.text?.isEmpty ?? true {
            return false
        }
        if usernameTextField.text?.isEmpty ?? true {
            return false
        }
        if passwordTextField.text?.isEmpty ?? true {
            return false
        }
        if repeatPasswordTextField.text?.isEmpty ?? true {
            return false
        }
        if passwordTextField.text != repeatPasswordTextField.text {
            return false
        }
        
        return true
    }
}
