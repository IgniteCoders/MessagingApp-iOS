//
//  NewChatViewController.swift
//  LoginApp
//
//  Created by Mañanas on 30/4/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class NewChatViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    
    var originalList: [User] = []
    var list: [User] = []
    var didSelectUser: ((User) -> Void)? = nil
    
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let search = UISearchController(searchResultsController: nil)
        //search.delegate = self
        search.searchBar.delegate = self
        self.navigationItem.searchController = search
        
        tableView.dataSource = self
        tableView.delegate = self
        
        fetchUsers()
    }
    
    // MARK: TableView DataSource & Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = list[indexPath.row]
        
        let cell: ContactViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactViewCell
        
        cell.render(user: item)
        //cell.titleLabel.text = item.name
        //cell.subtitleLabel.text = item.dates
        //cell.signImageView.image = item.image
        
        return cell
    }
    
    /*func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }*/
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didSelectUser!(list[indexPath.row])
        dismiss(animated: true)
    }
    
    // MARK: SearchBar delegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        list = originalList
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.isEmpty) {
            list = originalList
        } else {
            list = originalList.filter({ user in
                user.fullName().localizedCaseInsensitiveContains(searchText)
            })
        }
        tableView.reloadData()
    }
    
    // MARK: Data
    
    func fetchUsers() {
        let userID = Auth.auth().currentUser!.uid
        
        let db = Firestore.firestore()
        
        var users = [User]()
        Task {
            do {
                let querySnapshot = try await db.collection("Users").getDocuments()
                
                for document in querySnapshot.documents {
                    var user = try document.data(as: User.self)
                    users.append(user)
                }
                
                originalList = users
                list = originalList
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Error reading chats: \(error)")
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    @IBAction func cancel(_ sender: UIStoryboardSegue) {
        self.dismiss(animated: true)
    }

}
