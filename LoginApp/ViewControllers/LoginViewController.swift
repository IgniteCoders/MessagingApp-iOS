//
//  ViewController.swift
//  LoginApp
//
//  Created by Mañanas on 17/4/24.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import FirebaseFirestoreInternal

class LoginViewController: UIViewController {
    
    // MARK: Outlets

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if (SessionManager.isLoggedIn()) {
            navigateToHome()
        }
    }
    
    // MARK: Actions
    
    @IBAction func singInButton(_ sender: UIButton) {
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        
        Auth.auth().signIn(withEmail: username, password: password) { [unowned self] authResult, error in
            //guard let strongSelf = self else { return }
            // ...
            if (error == nil) {
              // Correcto
                if (authResult!.user.isEmailVerified) {
                    SessionManager.setSession(forUser: username, andPassword: password, withProvider: LoginProvider.basic)
                    self.navigateToHome()
                } else {
                    self.navigateToVerifyEmail()
                }
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    @IBAction func googleSignInButton(_ sender: UIButton) {
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                print("No token found in GoogleSignIn")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                // At this point, our user is signed in
                Task {
                    await self.createUser(googleUser: user)
                    
                    DispatchQueue.main.async {
                        SessionManager.setSession(forUser: user.profile!.email, andPassword: "", withProvider: LoginProvider.google)
                        
                        self.navigateToHome()
                    }
                }
            }
        }
    }
    
    func createUser(googleUser: GIDGoogleUser) async {
        let userID = Auth.auth().currentUser!.uid
        
        let db = Firestore.firestore()
        
        let docRef = db.collection("Users").document(userID)
        
        do {
            let document = try await docRef.getDocument()
            if !document.exists {
                let username = googleUser.profile!.email
                let firstName = googleUser.profile!.givenName ?? googleUser.profile!.name
                let lastName = googleUser.profile!.familyName ?? ""
                //let birthday = nil
                let gender = Gender.unspecified
                let profileImageUrl = googleUser.profile!.hasImage ? googleUser.profile!.imageURL(withDimension: 200) : nil
                
                let user = User(id: userID, username: username, firstName: firstName, lastName: lastName, gender: gender, birthday: nil, provider: .google, profileImageUrl: profileImageUrl?.absoluteString)
                
                do {
                    try db.collection("Users").document(userID).setData(from: user)
                } catch let error {
                    print("Error writing user to Firestore: \(error)")
                }
            }
        } catch {
            print("Error getting document: \(error)")
        }
    }
    
    @IBAction func forgotPassword(_ sender: UIButton) {
        let username = usernameTextField.text!
        Auth.auth().sendPasswordReset(withEmail: username) { error in
            if (error != nil) {
                print(error!.localizedDescription)
            }
        }
        let alert = UIAlertController(title: "Recuperar contraseña", message: "Te hemos enviado un correo a \(username) para recuperar tu contraseña.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true)
    }
    
    // MARK: Navigation & Segues
    
    func navigateToHome() {
        self.performSegue(withIdentifier: "navigateToHome", sender: self)
    }
    
    func navigateToVerifyEmail() {
        self.performSegue(withIdentifier: "navigateToEmailVerification", sender: self)
    }
}

