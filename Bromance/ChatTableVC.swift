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

    var convoDict = [String]()         //dictionary holds all users info
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkConvoId()
        tableView.reloadData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //show most recent contact person here
        
        
        //delete conversation, take away conversation id from only, do not delete the entire chat log
        
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
//        print("count is \(count)")
        return count
    }
    


    func checkConvoId() {
        
        let myid = user?.uid
        let contactedUserArrayRef = rootRef.child("user_profile/\(myid!)/conversation_id")
//        print(contactedUserRef)
        contactedUserArrayRef.observe(.value, with: {(snapshot) in
            if (snapshot.value as? NSArray) == nil {
//                print("do nothing")
            } else {
                self.convoDict = (snapshot.value as? Array)! //store JSON in userDict
                self.tableView.reloadData()

//                print(self.convoDict)
//                print(self.convoDict[0])
            }
        })
    }
    
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tablecell", for: indexPath) as! ChatTableCell
        
        var receiverId: String
        let convoId = self.convoDict[indexPath.row] as String
        
        //remove the the first 10 char from the string and get the contacted user's id
        receiverId = convoId
        receiverId.removeSubrange(receiverId.startIndex..<receiverId.index(receiverId.startIndex, offsetBy: 10))

        let contactedUserRef = rootRef.child("user_profile/\(receiverId)/")
        contactedUserRef.observe(.value, with: {(snapshot) in
            if let userDict = snapshot.value as? NSDictionary {
                cell.username.text = (userDict["username"] as! String).components(separatedBy: " ")[0]

            }
                
        })
        
        
        
//        cell.username =
        

        return cell
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
