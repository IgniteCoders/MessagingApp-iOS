//
//  ChatViewController.swift
//  LoginApp
//
//  Created by Mañanas on 26/4/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    
    // MARK: Properties
    
    var chat: Chat?
    var list: [Message] = []
    let userID = Auth.auth().currentUser!.uid
    
    var listener: ListenerRegistration? = nil
    
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageInputView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendMessageButton: UIButton!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        //tableView.transform = CGAffineTransformMakeScale (1, -1);
        
        // Customize the profile ImageView
        profileImageView.roundCorners()
        messageTextView.setBorder(width: 1, color: UIColor.lightGray.cgColor)
        messageTextView.roundCorners(radius: 5)
        messageTextView.delegate = self
        
        self.navigationItem.title = chat?.name
        chat!.users { users in
            let users = users.filter { user in
                user.id != Auth.auth().currentUser?.uid
            }
            let profileImage = users.first?.profileImageUrl
            if profileImage != nil && !profileImage!.isEmpty {
                self.profileImageView.loadFrom(url: profileImage!)
            }
        }
        
        //fetchMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let db = Firestore.firestore()
        listener = db.collection("Messages").whereField("chatId", isEqualTo: chat!.id).order(by: "date")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                
                do {
                    self.list = []
                    for document in documents {
                        let message = try document.data(as: Message.self)
                        self.list.append(message)
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        if (self.list.count > 0) {
                            let lastIndexPath = IndexPath(item:self.list.count - 1, section: 0)
                            self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
                        }
                    }
                } catch {
                    print("Error reading messages: \(error)")
                }
            }
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
        
        let cell: MessageViewCell = if item.senderId == userID {
            tableView.dequeueReusableCell(withIdentifier: "current", for: indexPath) as! MessageViewCell
        } else {
            tableView.dequeueReusableCell(withIdentifier: "other", for: indexPath) as! MessageViewCell
        }
        
        cell.render(message: item)
        //cell.contentView.transform = CGAffineTransformMakeScale (1, -1);
        //cell.titleLabel.text = item.name
        //cell.subtitleLabel.text = item.dates
        //cell.signImageView.image = item.image
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = list[indexPath.row]
        
        // height + margin + dateLabel.height
        return item.message.sizeWithFont(font: UIFont.systemFont(ofSize: 17), forWidth: 228).height + 32 + 20
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(list[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: TextView Delegate
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text!.replacingOccurrences(of: " ", with: "").isEmpty {
            sendMessageButton.isEnabled = false
        } else {
            sendMessageButton.isEnabled = true
        }
        
        let size = CGSize(width: textView.frame.size.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        guard textView.contentSize.height < 100 else {
            textView.isScrollEnabled = true
            return
        }
        
        textView.isScrollEnabled = false
        textView.constraints.forEach { constraint in
            if (constraint.firstAttribute == .height) {
                constraint.constant = estimatedSize.height
            }
        }
        
        messageInputView.constraints.forEach { constraint in
            if (constraint.firstAttribute == .height) {
                constraint.constant = estimatedSize.height + 16
            }
        }
        //textView.frame.size.height = estimatedSize.height
    }
    
    // MARK: Data
    
    func fetchMessages() {
        let db = Firestore.firestore()
        
        var messages = [Message]()
        Task {
            do {
                let querySnapshot = try await db.collection("Messages").whereField("chatId", isEqualTo: chat!.id).order(by: "date").getDocuments()
                
                for document in querySnapshot.documents {
                    let message = try document.data(as: Message.self)
                    messages.append(message)
                }
                
                list = messages
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Error reading messages: \(error)")
            }
        }
    }
    
    // MARK: Actions

    @IBAction func sendMessageButton(_ sender: UIButton) {
        let userID = Auth.auth().currentUser!.uid
        
        let message = Message(message: messageTextView.text!, date: Date.now.timeIntervalSince1970, senderId: userID, chatId: chat!.id)
        
        let db = Firestore.firestore()
        
        do {
            try db.collection("Messages").addDocument(from: message)
            messageTextView.text = ""
            textViewDidChange(messageTextView)
        } catch let error {
            print("Error writing user to Firestore: \(error)")
        }
    }
}
