//
//  NewChatViewController.swift
//  LoginApp
//
//  Created by Mañanas on 30/4/24.
//

import UIKit
import FirebaseAuth

class NewChatViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    
    var originalList: [User] = []
    var list: [User] = []
    // Lambda function to return selected user
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true)
        didSelectUser!(list[indexPath.row])
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
        Task {
            originalList = await DataManager.getUsers()
            list = originalList
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func cancel(_ sender: UIStoryboardSegue) {
        self.dismiss(animated: true)
    }

}
