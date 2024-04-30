//
//  ProfileViewController.swift
//  LoginApp
//
//  Created by Mañanas on 23/4/24.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Properties
    
    var user: User?
    
    // MARK: Outlets
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var genderImageView: UIImageView!
    @IBOutlet weak var birthdayDatePicker: UIDatePicker!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Customize the profile ImageView
        profileImageView.roundCorners()
        profileImageView.setBorder(width: 3, color: UIColor.systemBlue.cgColor)
        
        // Get the user data at start
        fetchUser()
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
    
    @IBAction func selectProfileImage(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        saveUser()
    }
    
    // MARK: Internal
    
    func fetchUser() {
        let userID = Auth.auth().currentUser!.uid
        
        let db = Firestore.firestore()
        
        let docRef = db.collection("Users").document(userID)

        Task {
            do {
                user = try await docRef.getDocument(as: User.self)
                print("User: \(user.debugDescription)")
                
                if user?.profileImageUrl != nil && !user!.profileImageUrl!.isEmpty {
                    profileImageView.loadFrom(url: user!.profileImageUrl!)
                } else {
                    profileImageView.image = UIImage(systemName: "person.circle.fill")
                }
                firstNameTextField.text = user?.firstName
                lastNameTextField.text = user?.lastName
                usernameTextField.text = user?.username
                birthdayDatePicker.date = user?.birthday ?? Date()
                genderSegmentedControl.selectedSegmentIndex = switch user?.gender {
                case .male:
                    0
                case .female:
                    1
                case .other:
                    2
                default:
                    -1
                }
                genderSegmentedControl(genderSegmentedControl)
            } catch {
                print("Error decoding user: \(error)")
            }
        }
    }
    
    func saveUser() {
        let userID = Auth.auth().currentUser!.uid
        
        user?.firstName = firstNameTextField.text!
        user?.lastName = lastNameTextField.text!
        user?.birthday = birthdayDatePicker.date
        user?.gender = switch genderSegmentedControl.selectedSegmentIndex {
        case 0:
            Gender.male
        case 1:
            Gender.female
        default:
            Gender.other
        }
        
        let db = Firestore.firestore()
        
        do {
            try db.collection("Users").document(userID).setData(from: user)
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
        
        return true
    }

    // MARK: ImagePicker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        profileImageView.image = image
        
        let data = image.jpegData(compressionQuality: 0.8)
        
        let userID = Auth.auth().currentUser!.uid
        let storage = Storage.storage()
        let storageRef = storage.reference()

        // Create a reference to the file you want to upload
        let profileRef = storageRef.child("\(userID)/profile.jpg")
        
        // Upload the file to the path "{userID}/profile.jpg"
        let uploadTask = profileRef.putData(data!, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            // You can also access to download URL after upload.
            profileRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                
                self.user?.profileImageUrl = downloadURL.absoluteString
            }
        }

        dismiss(animated: true)
    }

    /*func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }*/
}
