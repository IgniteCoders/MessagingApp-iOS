//
//  HomeViewController.swift
//  LoginApp
//
//  Created by Mañanas on 18/4/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    
    var list: [Chat] = []
    
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchChats()
    }
    
    // MARK: TableView DataSource & Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = list[indexPath.row]
        
        let cell: ChatViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChatViewCell
        
        cell.render(chat: item)
        //cell.titleLabel.text = item.name
        //cell.subtitleLabel.text = item.dates
        //cell.signImageView.image = item.image
        
        return cell
    }
    
    /*func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }*/
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(list[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Data
    
    func fetchChats() {
        let userID = Auth.auth().currentUser!.uid
        
        let db = Firestore.firestore()
        
        var chats = [Chat]()
        Task {
            do {
                let querySnapshot = try await db.collection("Chats").getDocuments()
                
                for document in querySnapshot.documents {
                    var chat = try document.data(as: Chat.self)
                    chats.append(chat)
                }
                
                list = chats
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Error reading chats: \(error)")
            }
        }
    }
    
    // MARK: Segues & Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "newChat") {
            let navigationViewController: UINavigationController = segue.destination as! UINavigationController
            let viewController: NewChatViewController = navigationViewController.topViewController as! NewChatViewController
            
            viewController.didSelectUser = { user in
                print(user)
                
                
            }
        } else {
            guard let indexPath = tableView.indexPathForSelectedRow else {
                print("No chat selected")
                return
            }
            
            let chat = list[indexPath.row]
            
            let viewController: ChatViewController = segue.destination as! ChatViewController
            
            viewController.chat = chat
        }
    }
}
