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

    var convoDict = [String]()              //dictionary holds all conversation id belogs to the current user
    var contactedUsersArray = [AnyObject]() //holds all contacted users info

    //pass following data to ChatViewController
    var name: String = ""
    var sendId: String = ""
    var receiveId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkConvoId()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    
        
        //***To do ***delete conversation, take away conversation id from only, do not delete the entire chat log
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var count = 0
        if self.convoDict.count > 0 {
            count = self.convoDict.count
        }
        //print("count is \(count)")
        return count
    }
    
    //load recently contacted users and chat
    func checkConvoId() {
        
        let myid = user?.uid
        let contactedUserArrayRef = rootRef.child("user_profile/\(myid!)/conversation_id")
        //print(contactedUserRef)
        contactedUserArrayRef.observe(.value, with: {(snapshot) in
            if (snapshot.value as? NSArray) == nil {
                //print("do nothing")
            } else {
                self.convoDict = (snapshot.value as? Array)! //store JSON in userDict
                self.tableView.reloadData()
            }
        })
    }
    
    //handles to tab, nav to chatViewController and pass data
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //parsing convoDict into readable username and receiver id
        let convoId = self.convoDict[indexPath.row] as String
        self.receiveId = convoId
        
        //pass the following info into ChatViewController
        self.receiveId = removeChar(someString: self.receiveId)
        self.sendId = (self.user?.uid)!
        let thisString = self.contactedUsersArray[indexPath.row].object(forKey: "username") as! String
        self.name = thisString.components(separatedBy: " ")[0]

        // handle tap events
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
        chatVC.senderId = self.sendId
        chatVC.senderDisplayName = self.name
        chatVC.receiverId = self.receiveId
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    //load data to cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tablecell", for: indexPath) as! ChatTableCell
        
        let convoId = self.convoDict[indexPath.row] as String
        
        //remove the the first 10 char from the string and get the contacted user's id
        self.receiveId = convoId
        self.receiveId = removeChar(someString: self.receiveId)
        
        let insideCellForRowAt = true
        self.observeUserProfile(conersationId: convoId, cell: cell, insideCellForRowAt: insideCellForRowAt)

        return cell
    }
    
    
    //remove the first 10 chars on the string
    private func removeChar(someString: String) -> String{
        var thisString = someString
        thisString.removeSubrange(thisString.startIndex..<thisString.index(thisString.startIndex, offsetBy: 10))
        return thisString
    }
    
    
    //retrieve entire user profile data
    private func observeUserProfile(conersationId: String, cell: ChatTableCell, insideCellForRowAt: Bool) {

        let contactedUserRef = rootRef.child("user_profile/\(receiveId)/")
        contactedUserRef.observe(.value, with: {(snapshot) in
            if let userDict = snapshot.value as? NSDictionary {
                
                //add current uesrDict to contactedUsersArray
                self.contactedUsersArray.append(userDict)
                
                let thisUsername = (userDict["username"] as! String).components(separatedBy: " ")[0]
                
                //only runs the following if inside tableview for display
                if insideCellForRowAt == true {
                    cell.username.text = thisUsername
                    self.observeProfilePic(userDict: userDict, cell: cell)
                    self.observeLastText(conversationId: conersationId, cell: cell)
                }
                
            }
        })
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
            
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let date = messageData["date"], let text = messageData["text"] as String!, text.characters.count > 0 {
                
                cell.lastText.text = text
                cell.dateSent.text = date
                
            } else {
                print("Error! Could not decode message data")
            }
        })//end message query *************************
    }
    
    //retrieve profile picture, if non setup then use a default profile image
    private func observeProfilePic(userDict: NSDictionary , cell: ChatTableCell){
        //*************************
        //display user image (make sure image is avaialbe and permission to access)
        if let imageURL = NSURL(string: userDict["profile_pic_small"] as! String) {
            if let imageData = NSData(contentsOf: imageURL as URL) {   //convert image nsurl to nsdata
                cell.profilePic.image = UIImage(data: imageData as Data)    //display profile image
            } else {
                if let defaultImageURL = NSURL(string: "https://firebasestorage.googleapis.com/v0/b/bromance-e91d8.appspot.com/o/default%2Fprofile_pic_small.jpg?alt=media&token=02d85d91-ac43-4a0b-a8f6-32b0821b51e4") {
                    if let defaultImageData = NSData(contentsOf: defaultImageURL as URL) {   //convert image nsurl to nsdata
                        cell.profilePic.image = UIImage(data: defaultImageData as Data)    //display profile image
                    }
                }
            }//end else
        }// end if *************************
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

