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

class ChatTableVC: UITableViewController {

    let rootRef = FIRDatabase.database().reference()    //reference to firebase database

    //pass following data to ChatViewController
//    var name: String = ""
//    var receiveId: String = ""
//    var chatPartnerId: String = ""
    
    var messages = [Message]()
    var messageDictionary = [String:Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\n\n\n")
    }


    override func viewWillAppear(_ animated: Bool) {
        self.checkConvoId()
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
                self.fetchMessageWithMessageId(messageId: messageId)
            }, withCancel: nil)
        }, withCancel: nil)//end observe
    }
    

    //retrive last text
    private func fetchMessageWithMessageId(messageId: String) {
        let messagesReference = FIRDatabase.database().reference().child("messages").child(messageId)
        let messageQuery = messagesReference.queryLimited(toLast:1)

        messageQuery.observeSingleEvent(of: .childAdded, with: { (snapshot) in
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
                        self.tableView.reloadData()
                    }
                }//end DispatchQueue
                
            }
        }, withCancel: nil)
    }
    

    //handles to tab, nav to chatViewController and pass data
    override func tableView(_  ableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //using pre-downloaded JSON to partse user profile and receiverID, then pass data to chatVC
//        if self.contactedUsersArray.count > 0 && self.usersKeyArray.count > 0 {
//            let currentChatPartnerID = self.usersKeyArray[indexPath.row] 
//            let currentChatPartnerProfile = self.contactedUsersArray[indexPath.row] as! NSDictionary
//            
//            //pass the following info into ChatViewController
//            self.receiveId = currentChatPartnerID
//            guard let sendId = FIRAuth.auth()?.currentUser?.uid else {
//                return
//            }
//            //get receiver's uesrname
//            let thisUser = User(dict: currentChatPartnerProfile as! [String : NSObject]) //Helper: User, parse JSON
//            let thisString = thisUser.username
//            self.name = (thisString?.components(separatedBy: " ")[0])!
        

//
//            self.navigationController?.pushViewController(chatVC, animated: true)
//        }//end if
        
        let message = messages[(indexPath as NSIndexPath).row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user_profile").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            guard let sendId = FIRAuth.auth()?.currentUser?.uid else {
                return
            }

            


            print(dictionary)

            // handle tap events, segue to chatVC
            let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
            chatVC.senderId = sendId
            chatVC.senderDisplayName = dictionary["username"] as! String!
            chatVC.receiverId = chatPartnerId
            self.navigationController?.pushViewController(chatVC, animated: true)

            
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
        return messages.count
    }
 
    //    //remove the first 10 chars on the string
    //    private func removeChar(someString: String) -> String{
    //        var thisString = someString
    //        thisString.removeSubrange(thisString.startIndex..<thisString.index(thisString.startIndex, offsetBy: 10))
    //        return thisString
    //    }

}

