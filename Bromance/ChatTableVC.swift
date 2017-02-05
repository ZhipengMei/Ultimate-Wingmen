//
//  ChatTableVC.swift
//  Bromance
//
//  Created by Zhipeng Mei on 1/4/17.
//  Copyright © 2017 Team Grit. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import UserNotifications
import SVProgressHUD

class ChatTableVC: UITableViewController {
    
    let rootRef = FIRDatabase.database().reference()    //reference to firebase database
    var messages = [Message]()
    var messageDictionary = [String:Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.downloadCurrentUserInfo() //cache image ahead of time
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.checkConvoId()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        rootRef.removeAllObservers()
    }
    
    //load recently contacted users and chat
    func checkConvoId() {
        guard let myid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let contactedUserArrayRef = rootRef.child("user_messagesId/\(myid)")
        contactedUserArrayRef.observe(.childAdded, with: {(snapshot) in
            
            let userId = snapshot.key
            FIRDatabase.database().reference().child("user_messagesId").child(myid).child(userId).observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                self.fetchLastTextWithMessageId(messageId: messageId)
            }, withCancel: nil)
            
        }, withCancel: nil)//end observe
    }
    
    
    //retrive last text
    private func fetchLastTextWithMessageId(messageId: String) {
        SVProgressHUD.show()
        let messagesReference = FIRDatabase.database().reference().child("messages").child(messageId)
        let messageQuery = messagesReference.queryLimited(toLast:1)
        
        messageQuery.observe(.childAdded, with: { (snapshot) in
            if let snapDict = snapshot.value as? NSDictionary{
                let message = Message(dict: snapDict as! [String : NSObject])
                
                // match chatPartnerId to the message
                if let chatPartnerId = message.chatPartnerId() {
                    self.messageDictionary[chatPartnerId] = message
                }
                
                //sort mesages based on the timestamp
                self.messages = Array(self.messageDictionary.values)
                self.messages.sort(by: { (message1, message2) -> Bool in
                    return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
                })
                
                DispatchQueue.global(qos: .userInitiated).async {
                    // Bounce back to the main thread to update the UI
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        self.tableView.reloadData()
                    }
                }//end DispatchQueue
                
            }
        }, withCancel: nil)
    }
    
    //load data to cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tablecell", for: indexPath) as! ChatTableCell
        
        let message = messages[(indexPath as NSIndexPath).row]
        cell.message = message
        
        return cell
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messages.count == 0{
            let frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
            let emptyLabel = UILabel(frame: frame)
            emptyLabel.text = "No messages found"
            emptyLabel.textAlignment = NSTextAlignment.center
            self.tableView.backgroundView = emptyLabel
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
            return 0
        } else {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
            return messages.count
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        guard let sendId = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        //function to download user profile
        observeHelper.loadUserProfileUsingCache(thisUid: chatPartnerId) { (userprofile, error) in
            if error != nil {
                print("observeHelper error: \(error!)")
            } else {
                // do something with the userprofile
                if let chatVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatVC") as? ChatViewController {
                    chatVC.senderId = sendId
                    chatVC.senderDisplayName = userprofile?.username
                    chatVC.receiverId = chatPartnerId
                    if let navigator = self.navigationController {
                        navigator.pushViewController(chatVC, animated: true)
                    }
                }
            }
        }//end observeHelper
        
    }
    
    //cached image ahead of time, for later use purpose. Advise not to delete
    func downloadCurrentUserInfo() {
        //function to download user profile
        guard let userUid = FIRAuth.auth()?.currentUser?.uid else { return }
        observeHelper.loadUserProfileUsingCache(thisUid: userUid) { (userprofile, error) in
            if error != nil {
                print("observeHelper error: \(error!)")
            } else {
                //check cached image
                if let ImageUrl = userprofile?.profile_pic_small {
                    //アバターの設定
                    let imageView = UIImageView()
                    imageView.loadImageUsingCache(urlString: URL(string:ImageUrl)!)
                }
            }
        }//end observeHelper
    }
    
    //    //remove the first 10 chars on the string
    //    private func removeChar(someString: String) -> String{
    //        var thisString = someString
    //        thisString.removeSubrange(thisString.startIndex..<thisString.index(thisString.startIndex, offsetBy: 10))
    //        return thisString
    //    }
}

