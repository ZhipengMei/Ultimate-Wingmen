//
//  ChatViewController.swift
//  Bromance
//
//  Created by Zhipeng Mei on 12/31/16.
//  Copyright © 2016 Team Grit. All rights reserved.
//  Tutorial: https://www.raywenderlich.com/140836/firebase-tutorial-real-time-chat-2

import UIKit
import JSQMessagesViewController
import FirebaseDatabase
import FirebaseAuth

class ChatViewController: JSQMessagesViewController {

    var messages = [JSQMessage]()
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
//    private lazy var messageRef: FIRDatabaseReference = self.root.child("messages")
//    private var newMessageRefHandle: FIRDatabaseHandle?
    
    var receiverData: AnyObject!
    var receiverId: String!
    var conversationID: String?
    var rootRef = FIRDatabase.database().reference()    //reference to firebase database
    
    var convoIDarray = [String]()                //array contains a list of users id
//    var convoIDset = Set<String>()
    
    var convoDict = [String]()         //dictionary holds all users info
    var convoDictSet = Set<String>()         //dictionary holds all users info

    
//    private var userIsTypingRef: AnyObject?// 1
//    private var localTyping = false // 2
//    var isTyping: Bool {
//        get {
//            return localTyping
//        }
//        set {
//            // 3
//            localTyping = newValue
//            self.userIsTypingRef!.setValue(newValue)
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = senderDisplayName
        
        //setup bubbles
        setupIncomingBubble()
        setupOutgoingBubble()
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero

        let receiverIdFive = String(receiverId.characters.prefix(5))
        let senderIdFive = String(senderId.characters.prefix(5))
        //setting up conversation id
        if(senderIdFive > receiverIdFive) {
            self.conversationID = senderIdFive + receiverIdFive + self.receiverId
        } else {
            self.conversationID = receiverIdFive + senderIdFive + self.receiverId
        }
  
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        
        observeMessages()
//        observeTyping()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    //add a new message
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
            //try append name
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        //acutal sender name is the current user
        let senderName = FIRAuth.auth()?.currentUser?.displayName
        //get the current time
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd.yyyy"
        let result = formatter.string(from: date)


        let itemRef = rootRef.child("messages").child("\(self.conversationID!)").childByAutoId() // 1

        let messageItem = [ // 2
            "senderId": senderId!,
            "senderName": senderName,
            "text": text!,
            "date": result
            ]
        itemRef.setValue(messageItem) // 3
        JSQSystemSoundPlayer.jsq_playMessageSentSound() // 4
        finishSendingMessage() // 5
        
        updateConvoIdInfo()
        
//        isTyping = false
    }
    
    //update an array of conversation id, use it to show recently contacted users
    func updateConvoIdInfo() {
        
        let contactedUserRef = rootRef.child("user_profile/\(senderId!)").child("conversation_id")
        var runItOnce = false
        
        contactedUserRef.observe(.value , with: {(snapshot) in
            if (snapshot.value as? NSArray) == nil {
                
                if runItOnce == false {
                    self.convoIDarray.insert(self.conversationID!, at: 0)
                    contactedUserRef.setValue(self.convoIDarray)
                    runItOnce = true
                }
                
            } else {
                
                if runItOnce == false {
                    self.convoDict = (snapshot.value as? Array)! //store JSON in userDict
                    //print("\n\n\nself.convoDict \(self.convoDict)")
                    
                    if let indexOfA = self.convoDict.index(of: self.conversationID!) {
                        self.convoDict.remove(at: indexOfA)
                        self.convoDict.insert(self.conversationID!, at: 0)
                    } else {
                        self.convoDict.insert(self.conversationID!, at: 0)
                    }
                    contactedUserRef.setValue(self.convoDict)
                    runItOnce = true
                }


            }
        })
    }
    
    
    private func observeMessages() {
        let messageRef = rootRef.child("messages/\(self.conversationID!)")
        // 1.
        let messageQuery = messageRef.queryLimited(toLast:25)
        
        // 2. We can use the observe method to listen for new
        // messages being written to the Firebase DB
        messageQuery.observe(.childAdded, with: { (snapshot) in
            // 3
            let messageData = snapshot.value as! Dictionary<String, String>
            //print(messageData)

            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.characters.count > 0 {
                // 4
                self.addMessage(withId: id, name: name, text: text)
                
                // 5
                self.finishReceivingMessage()
            } else {
                print("Error! Could not decode message data")
            }
        })//end message query
    }
    
//    override func textViewDidChange(_ textView: UITextView) {
//        super.textViewDidChange(textView)
//        // If the text is not empty, the user is typing
//        isTyping = textView.text != ""
//    }
//    
//    private func observeTyping() {
//        let typingIndicatorRef = rootRef.child("messages/\(self.conversationID!)").child("typingIndicator")
//        userIsTypingRef = typingIndicatorRef.child(senderId)
//        userIsTypingRef?.onDisconnectRemoveValue()
//        
//        let userTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqual(toValue: true)
//        
//        userTypingQuery.observe(.value, with: {(snapshot: FIRDataSnapshot) in
//        
//            if (snapshot.childrenCount == 1 && self.isTyping) {
//                return
//            }
//            
//            self.showTypingIndicator = snapshot.childrenCount > 0
//            self.scrollToBottom(animated: true)
//        
//        })
//    }
    
    

}
