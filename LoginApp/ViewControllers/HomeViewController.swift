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
    var newChatId: String? = nil
    
    var listener: ListenerRegistration? = nil
    
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
        //fetchChats()
        
        listener = DataManager.getChatsListener(completion: { [unowned self] chats in
            self.list = chats
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
    }
    
    // MARK: TableView DataSource & Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = list[indexPath.row]
        
        let cell: ChatViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChatViewCell
        
        cell.render(chat: item)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(list[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Data
    
    func fetchChats() {
        Task {
            list = await DataManager.getChats()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: Segues & Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "newChat") {
            let navigationViewController: UINavigationController = segue.destination as! UINavigationController
            let viewController: NewChatViewController = navigationViewController.topViewController as! NewChatViewController
            
            viewController.didSelectUser = { [unowned self] user in
                self.didSelectUser(user: user)
            }
        } else {
            var chat: Chat? = nil
            if (newChatId != nil) {
                chat = list.first(where: { chat in
                    chat.id == newChatId
                })
                newChatId = nil
            } else {
                guard let indexPath = tableView.indexPathForSelectedRow else {
                    print("No chat selected")
                    return
                }
                
                chat = list[indexPath.row]
            }
            
            let viewController: ChatViewController = segue.destination as! ChatViewController
            
            viewController.chat = chat
        }
    }
    
    func didSelectUser(user: User) {
        
        let exist = self.list.first { chat in
            chat.participants!.contains(where: { u in
                u.id == user.id
            })
        }
        if exist != nil {
            self.newChatId = exist?.id
            self.performSegue(withIdentifier: "chat", sender: self)
        } else {
            Task {
                guard let chat = await DataManager.createChat(withUser: user) else {
                    return
                }
                //list.append(chat)
                self.newChatId = chat.id
                self.performSegue(withIdentifier: "chat", sender: self)
            }
        }
    }
}
