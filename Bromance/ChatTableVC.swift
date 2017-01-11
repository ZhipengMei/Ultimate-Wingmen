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

    let user = FIRAuth.auth()?.currentUser
    let rootRef = FIRDatabase.database().reference()    //reference to firebase database

    var convoDict = [AnyObject]()              //dictionary holds all conversation id belogs to the current user
    var contactedUsersArray = [AnyObject]() //holds all contacted users info
    var chatIDArray = [String]()            //holds all all conversation id in array
    var usersKeyArray = [String]()            //holds all all conversation id in array

    //pass following data to ChatViewController
    var name: String = ""
    var sendId: String = ""
    var receiveId: String = ""
    var chatPartnerId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    
        
        //***To do ***delete conversation, take away conversation id from only, do not delete the entire chat log
        
    }


    override func viewWillAppear(_ animated: Bool) {
        self.checkConvoId()
    }


    //load recently contacted users and chat
    func checkConvoId() {
        self.convoDict.removeAll() //reset it
        let myid = user?.uid
        let contactedUserArrayRef = rootRef.child("user_messagesId/\(myid!)")

        contactedUserArrayRef.observe(.value, with: {(snapshot) in
            if (snapshot.value as? NSDictionary) == nil {
                print("user_messagesId reference has nothing")
            } else {
                self.convoDict.append((snapshot.value as? NSDictionary)!) //store JSON in userDict
                
                // Move to a background thread to do some long running work
                DispatchQueue.global(qos: .userInitiated).async {
                    // Bounce back to the main thread to update the UI
                    DispatchQueue.main.async {
                        self.fetchContactedUsers()
                    }
                }//end DispatchQueue
            }//end else
        }, withCancel: nil)//end observe
    }
    

    
    
    
    
    //handles to tab, nav to chatViewController and pass data
    override func tableView(_  ableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //using pre-downloaded JSON to partse user profile and receiverID, then pass data to chatVC
        if self.contactedUsersArray.count > 0 && self.usersKeyArray.count > 0 {
            let currentChatPartnerID = self.usersKeyArray[indexPath.row] 
            let currentChatPartnerProfile = self.contactedUsersArray[indexPath.row] as! NSDictionary
            
            //pass the following info into ChatViewController
            self.receiveId = currentChatPartnerID
            self.sendId = (self.user?.uid)!
            
            //get receiver's uesrname
            let thisUser = User(dict: currentChatPartnerProfile as! [String : NSObject]) //Helper: User, parse JSON
            let thisString = thisUser.username
            self.name = (thisString?.components(separatedBy: " ")[0])!
            
            // handle tap events, segue to chatVC
            let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
            chatVC.senderId = self.sendId
            chatVC.senderDisplayName = self.name
            chatVC.receiverId = self.receiveId
            
            self.navigationController?.pushViewController(chatVC, animated: true)
        }//end if
    }
    
    //load data to cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tablecell", for: indexPath) as! ChatTableCell
        
        //using downloaded contacted users JSON to display them in table view
        if self.contactedUsersArray.count > 0 {
            let chatDict = self.contactedUsersArray[indexPath.row]
            
            let thisUser = User(dict: chatDict as! [String : NSObject]) //Helper: User, parse JSON
            cell.username.text = thisUser.username?.components(separatedBy: " ")[0]
            cell.profilePic.loadImageUsingCache(urlString: thisUser.profile_pic_small!)
            let chatID = self.chatIDArray[indexPath.row]
            self.observeLastText(conversationId: (chatID), cell: cell)
            
            
            
        }

        return cell
    }
    
    //download all contacted user's info
    func fetchContactedUsers() {
        self.contactedUsersArray.removeAll()
        self.chatIDArray.removeAll()
        
        if self.convoDict.count > 0 {
            for index in 0...(self.convoDict.count - 1){
                let chatPartnerDict = self.convoDict[index] as! NSDictionary
                for (key, value) in chatPartnerDict {
                    //use key to get user profle image and username
                    let userRef = FIRDatabase.database().reference().child("user_profile").child(key as! String)
                    var userRefHandle: UInt = 0
                    
                    userRefHandle = userRef.observe(.value , with: {(snapshot) in
                        
                        if let dictionary = snapshot.value as? [String: NSObject] {
                            self.contactedUsersArray.append(dictionary as AnyObject) //save the downloaded profile locally
                            self.usersKeyArray.append(key as! String)
                            let chatID = value as! Array<Any>               //converting nsarray into regular array
                            self.chatIDArray.append(chatID[0] as! String) //add conversation id into the array
                        }
                        
                        DispatchQueue.global(qos: .userInitiated).async {
                            // Bounce back to the main thread to update the UI
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }//end DispatchQueue
                        
                        userRef.removeObserver(withHandle: userRefHandle) //remove the observe once finished running
                    }, withCancel: nil) //end observe
                    
                }//end for
            }//end for
        }//end if
    }
    

    
 
    //retrieve last text and its date
    private func observeLastText(conversationId: String, cell: ChatTableCell) {
        //*************************
        //display last text
        let messageRef = self.rootRef.child("messages/\(conversationId)")
        let messageQuery = messageRef.queryLimited(toLast:1)
        
        // 2. We can use the observe method to listen for new
        // messages being written to the Firebase DB
        messageQuery.observe(.childAdded, with: { (snapshot) in
            // 3
            let messageData = snapshot.value as! Dictionary<String, String>
            
            //*** To DO **
            // sort the table view cell by the timestamp
            print(snapshot)
            
            if let senderid = messageData["senderId"] as String!,
                let receiverid = messageData["receiverId"] as String!,
                let name = messageData["senderName"] as String!,
                let timestamp = messageData["timestamp"] as String!,
                let text = messageData["text"] as String!,
                text.characters.count > 0 {
                
                cell.lastText.text = text
                
                //convert to readble time stamp
                let seconds = Double(timestamp)
                let timestampDate = NSDate(timeIntervalSince1970: seconds!)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                cell.dateSent.text = dateFormatter.string(from: timestampDate as Date)
                

            } else {
                print("Error! Could not decode message data")
            }
        }, withCancel: nil)//end message query *************************
    }

    
    
    
    
    
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if self.contactedUsersArray.count > 0 {
            count = self.contactedUsersArray.count
        }
        return count
    }
 
    //    //remove the first 10 chars on the string
    //    private func removeChar(someString: String) -> String{
    //        var thisString = someString
    //        thisString.removeSubrange(thisString.startIndex..<thisString.index(thisString.startIndex, offsetBy: 10))
    //        return thisString
    //    }

}

