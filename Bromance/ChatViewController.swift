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
import Photos
import FirebaseStorage

class ChatViewController: JSQMessagesViewController {

    var messages = [JSQMessage]()
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    var receiverId: String!
    var conversationID: String?
    var rootRef = FIRDatabase.database().reference()    //reference to firebase database
    
    private lazy var messageRef: FIRDatabaseReference = self.rootRef.child("messages")
    private var newMessageRefHandle: FIRDatabaseHandle?
    
    
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
    
    //firebase storage reference
    lazy var storageRef = FIRStorage.storage().reference()
    private let imageURLNotSetKey = "NOTSET"
    //display images
    private var photoMessageMap = [String: JSQPhotoMediaItem]()
    private var updatedMessageRefHandle: FIRDatabaseHandle?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
//        title = senderDisplayName
        self.setupNavBarWithUser()
        
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
            self.conversationID = senderIdFive + receiverIdFive
        } else {
            self.conversationID = receiverIdFive + senderIdFive
        }
  
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.view.backgroundColor = UIColor.white
        observeMessages()

    }
    
    //clean up observe when view disappear
    deinit {
        if let refHandle = newMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        
        if let refHandle = updatedMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
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
    private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem) {
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
            messages.append(message)
            
            if (mediaItem.image == nil) {
                photoMessageMap[key] = mediaItem
            }
            
            collectionView.reloadData()
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        //acutal sender name is the current user
        let senderName = FIRAuth.auth()?.currentUser?.displayName
        let timeStamp = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        let itemRef = rootRef.child("messages").child("\(self.conversationID!)").childByAutoId() // 1
        let messageItem = [ // 2
            "senderId": senderId!,
            "senderName": senderName!,
            "text": text!,
            "timestamp": timeStamp,
            "receiverId": receiverId!
            ] as [String : Any]
        
        itemRef.setValue(messageItem) // 3
        JSQSystemSoundPlayer.jsq_playMessageSentSound() // 4
        updateUserMessageId()
        finishSendingMessage() // 5
        
        
//        isTyping = false
    }
    
    //using fan-out method to create reference to the conversation id 
    func updateUserMessageId() {
        let senderMegRef = rootRef.child("user_messagesId").child(senderId!).child(receiverId!)
        let receiverMegRef = rootRef.child("user_messagesId").child(receiverId!).child(senderId!)
        senderMegRef.updateChildValues([self.conversationID!:1])
        receiverMegRef.updateChildValues([self.conversationID!:1])
    }

    private func observeMessages() {
        let messageRef = rootRef.child("messages/\(self.conversationID!)")
        // 1.
        let messageQuery = messageRef.queryLimited(toLast:25)
        
        // 2. We can use the observe method to listen for new
        // messages being written to the Firebase DB
        messageQuery.observe(.childAdded, with: { (snapshot) in
            // 3
            let messageData = snapshot.value as! Dictionary<String, AnyObject>
            //print(messageData)

            if let id = messageData["senderId"] as! String!, let name = messageData["senderName"] as! String!, let text = messageData["text"] as! String!, text.characters.count > 0 {
                // 4
                self.addMessage(withId: id, name: name, text: text)
                
                // 5
                self.finishReceivingMessage()
            } else if let id = messageData["senderId"] as! String!,
                let photoURL = messageData["photoURL"] as! String! { // 1
                // 2
                if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
                    // 3
                    self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
                    // 4
                    if photoURL.hasPrefix("gs://") {
                        self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                    }
                }
            } else {
                print("Error! Could not decode message data")
            }
        })//end message query
        
        
        // We can also use the observer method to listen for
        // changes to existing messages.
        // We use this to be notified when a photo has been stored
        // to the Firebase Storage, so we can update the message data
        updatedMessageRefHandle = messageRef.observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let messageData = snapshot.value as! Dictionary<String, String> // 1
            
            if let photoURL = messageData["photoURL"] as String! { // 2
                // The photo has been updated.
                if let mediaItem = self.photoMessageMap[key] { // 3
                    self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key) // 4
                }
            }
        })
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
    
    
    // sending images
    func sendPhotoMessage() -> String? {
        let itemRef = messageRef.childByAutoId()
        
        let messageItem = [
            "photoURL": imageURLNotSetKey,
            "senderId": senderId!,
            ]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        return itemRef.key
    }
    
    func setImageURL(_ url: String, forPhotoMessageWithKey key: String) {
        let itemRef = messageRef.child(key)
        itemRef.updateChildValues(["photoURL": url])
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            picker.sourceType = UIImagePickerControllerSourceType.camera
        } else {
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        present(picker, animated: true, completion:nil)
    }
    
    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        let storageRef = FIRStorage.storage().reference(forURL: photoURL)
        storageRef.data(withMaxSize: INT64_MAX){ (data, error) in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
            
            storageRef.metadata(completion: { (metadata, metadataErr) in
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    return
                }
                
                if (metadata?.contentType == "image/gif") {
                    mediaItem.image = UIImage.gifWithData(data!)
                } else {
                    mediaItem.image = UIImage.init(data: data!)
                }
                self.collectionView.reloadData()
                
                guard key != nil else {
                    return
                }
                self.photoMessageMap.removeValue(forKey: key!)
            })
        }
    }
    
    //image pic on nav title
    func setupNavBarWithUser() {
        
        //creating title view to hold container view
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
//        titleView.backgroundColor = UIColor.red
        
        let containerView = UIView() //container view to hold image view and name label
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileView = UIImageView()
        profileView.translatesAutoresizingMaskIntoConstraints = false
        profileView.contentMode = .scaleAspectFill
        profileView.layer.cornerRadius = 20
        profileView.clipsToBounds = true
        
        //function to download user profile
        observeHelper.loadUserProfileUsingCache(thisUid: self.receiverId) { (userprofile, error) in
            if error != nil {
                print("observeHelper error: \(error!)")
            } else {
                //check cached image
                if let profileImageUrl = userprofile?.profile_pic_small {
                    profileView.loadImageUsingCache(urlString: profileImageUrl)
                }
                containerView.addSubview(profileView)   //add image view to title view
                
                //ios9 constraint (image view stick to title view)
                profileView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
                profileView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
                profileView.widthAnchor.constraint(equalToConstant: 40).isActive = true
                profileView.heightAnchor.constraint(equalToConstant: 40).isActive = true
                
                
                //username label
                let nameLabel = UILabel()
                nameLabel.text = userprofile?.username
                nameLabel.textColor = UIColor.white
                nameLabel.translatesAutoresizingMaskIntoConstraints = false
                containerView.addSubview(nameLabel)
                
                //ios9 constraint (label stick to title view)
                nameLabel.leftAnchor.constraint(equalTo: profileView.rightAnchor, constant: 8).isActive = true
                nameLabel.centerYAnchor.constraint(equalTo: profileView.centerYAnchor).isActive = true
                nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
                nameLabel.heightAnchor.constraint(equalTo: profileView.heightAnchor).isActive = true
                
                
                //center container view with constraint
                containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
                containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
                
                self.navigationItem.titleView = titleView
                
                
                //add tapgesture to title view
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
                tapGesture.cancelsTouchesInView = true
                titleView.addGestureRecognizer(tapGesture)

            }
        }//end observeHelper
        
    }//end setupnavtitlebar
    
    //segue to user info page
    func handleTap() {
        if let profile = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileVC") as? ProfileVC {
            
            self.tabBarController?.tabBar.isHidden = true
            profile.userID = self.receiverId
            
            if let navigator = self.navigationController {
                navigator.pushViewController(profile, animated: true)
            }
        }
    }
    

}


// MARK: Image Picker Delegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion:nil)
        
        // 1
        if let photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as? URL {
            // Handle picking a Photo from the Photo Library
            // 2
            let assets = PHAsset.fetchAssets(withALAssetURLs: [photoReferenceUrl], options: nil)
            let asset = assets.firstObject
            
            // 3
            if let key = sendPhotoMessage() {
                // 4
                asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
                    let imageFileURL = contentEditingInput?.fullSizeImageURL
                    
                    // 5
                    let path = "\(FIRAuth.auth()?.currentUser?.uid)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(photoReferenceUrl.lastPathComponent)"
                    
                    // 6
                    self.storageRef.child(path).putFile(imageFileURL!, metadata: nil) { (metadata, error) in
                        if let error = error {
                            print("Error uploading photo: \(error.localizedDescription)")
                            return
                        }
                        // 7
                        self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                    }
                })
            }
        } else {
            // Handle picking a Photo from the Camera
            // 1
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            // 2
            if let key = sendPhotoMessage() {
                // 3
                let imageData = UIImageJPEGRepresentation(image, 1.0)
                // 4
                let imagePath = FIRAuth.auth()!.currentUser!.uid + "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
                // 5
                let metadata = FIRStorageMetadata()
                metadata.contentType = "image/jpeg"
                // 6
                storageRef.child(imagePath).put(imageData!, metadata: metadata) { (metadata, error) in
                    if let error = error {
                        print("Error uploading photo: \(error)")
                        return
                    }
                    // 7
                    self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                }
            }
        }//end else
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
}
