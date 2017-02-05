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
import MobileCoreServices
import AVKit
import Kingfisher
import SVProgressHUD

class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var messages = [JSQMessage]()

    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    var incomingAvatar: JSQMessagesAvatarImage!
    var outgoingAvatar: JSQMessagesAvatarImage!
    
    var receiverId: String!
    var conversationID: String?
    
    var rootRef = FIRDatabase.database().reference()    //reference to firebase database
    
    private lazy var messageRef: FIRDatabaseReference = self.rootRef.child("messages")
    private var newMessageRefHandle: FIRDatabaseHandle?

    //firebase storage reference
    lazy var storageRef = FIRStorage.storage().reference()
    private let imageURLNotSetKey = "NOTSET"
    //display images
    private var photoMessageMap = [String: JSQPhotoMediaItem]()
    private var updatedMessageRefHandle: FIRDatabaseHandle?
    
    let picker = UIImagePickerController() //pick image
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        
        self.setupNavBarWithUser()
        self.loadCurrentUserChatAvatar()

        //吹き出しの設定
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        self.incomingBubble = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        self.outgoingBubble = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
        
        let receiverIdFive = String(receiverId.characters.prefix(5))
        let senderIdFive = String(senderId.characters.prefix(5))
        //setting up conversation id
        if(senderIdFive > receiverIdFive) {
            self.conversationID = senderIdFive + receiverIdFive
        } else {
            self.conversationID = receiverIdFive + senderIdFive
        }
  
        observeMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.view.backgroundColor = UIColor.white
    }
    
    //load the image
    func loadCurrentUserChatAvatar(){
        //get current user photo
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
                    if imageView.image != nil {
                        self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: imageView.image, diameter: 64)
                    }
                    
                }
            }
        }//end observeHelper
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
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let msg = messages[indexPath.item]
        
        //do not support video so far
        if msg.isMediaMessage {
            //check if the media item a video
//            if let mediaItem = msg.media as? JSQVideoMediaItem {
//                let player = AVPlayer(url: mediaItem.fileURL)
//                let playerController = AVPlayerViewController()
//                playerController.player = player
//                self.present(playerController, animated: true, completion: nil)
//            }
        }
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1

        if message.senderId == senderId { // 2
            return outgoingBubble
        } else { // 3
            return incomingBubble
        }
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
//        return nil
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            return self.outgoingAvatar
        } else {
            return self.incomingAvatar
        }
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
    
    
    
    
    // ****** Loading messages Begin ******
    //using fan-out method to create reference to the conversation id
    func updateUserMessageId() {
        let senderMegRef = rootRef.child("user_messagesId").child(senderId!).child(receiverId!)
        let receiverMegRef = rootRef.child("user_messagesId").child(receiverId!).child(senderId!)
        senderMegRef.updateChildValues([self.conversationID!:1])
        receiverMegRef.updateChildValues([self.conversationID!:1])
    }

    private func observeMessages() {
        let messageRef = rootRef.child("messages/\(self.conversationID!)")
        let messageQuery = messageRef.queryLimited(toLast:25)
        
        // 2. We can use the observe method to listen for new
        // messages being written to the Firebase DB
        messageQuery.observe(.childAdded, with: { (snapshot) in
            let messageData = snapshot.value as! NSDictionary
            if let id = messageData["senderId"] as! String!, let name = messageData["senderName"] as! String!, let text = messageData["text"] as! String!, text.characters.count > 0 {
                SVProgressHUD.show()
                self.addMessage(withId: id, name: name, text: text)
                self.finishReceivingMessage()
                SVProgressHUD.dismiss()
                self.collectionView.reloadData()
            }
            
            else if let id = messageData["senderId"] as! String!, let name = messageData["senderName"] as! String!, let mediaURL = messageData["mediaURL"] as! String! {
                SVProgressHUD.show()
                let photo = AsyncPhotoMediaItem.init(withURL: NSURL(string: mediaURL)!)
                self.messages.append(JSQMessage(senderId: id, displayName: name, media: photo))
                self.finishReceivingMessage()
                SVProgressHUD.dismiss()
                self.collectionView.reloadData()
            }
        })//end message query
    }//end observe message
    // ****** Loading messages END ******


    
    
    
    // ****** Sending messages Begin ******
    //add a new message
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
            
            //try append name
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
            //            "unread": "true"
            ] as [String : Any]
        
        itemRef.setValue(messageItem) // 3
        JSQSystemSoundPlayer.jsq_playMessageSentSound() // 4
        updateUserMessageId()
        finishSendingMessage() // 5
    }
    
    //pick media files
    override func didPressAccessoryButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Media Message", message: "Please Select A Media", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let photos = UIAlertAction(title: "Photos", style: .default, handler: {
            (alert: UIAlertAction) in
            self.chooseMedia(type: kUTTypeImage)
        })
        
        //do not support video so far
//        let videos = UIAlertAction(title: "Videos", style: .default, handler: {
//            (alert: UIAlertAction) in
//            self.chooseMedia(type: kUTTypeMovie)
//        })
        
        alert.addAction(photos)
//        alert.addAction(videos)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    //picker functions for picking media files
    private func chooseMedia(type: CFString) {
        picker.mediaTypes = [type as String]
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pic = info[UIImagePickerControllerOriginalImage] as? UIImage {

            let data = UIImageJPEGRepresentation(pic, 0.01) //check image quality
            self.sendMedia(image: data, video: nil, senderID: senderId, senderName: senderDisplayName)
            
        }
//        else if let vidUrl = info[UIImagePickerControllerMediaURL] as? URL {
//            
//            self.sendMedia(image: nil, video: vidUrl, senderID: senderId, senderName: senderDisplayName)
//        
//        }
        
        //dismiss picker and reload data
        self.dismiss(animated: true, completion: nil)
        self.collectionView.reloadData()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }

    
    func sendMediaMessage(senderID: String, senderName: String, url:String) {
        let timeStamp = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        let itemRef = rootRef.child("messages").child("\(self.conversationID!)").childByAutoId() // 1
        let messageItem = [
            "senderId": senderId!,
            "senderName": senderName,
            "mediaURL": url,
            "timestamp": timeStamp,
            "receiverId": receiverId!
            ] as [String : Any]
        itemRef.setValue(messageItem) // 3
        JSQSystemSoundPlayer.jsq_playMessageSentSound() // 4
        updateUserMessageId()
    }
    //upload media to firebase
    func sendMedia(image:Data?, video:URL?, senderID:String, senderName: String) {
        if image != nil {
            SVProgressHUD.show()
            self.storageRef.child("imageStorage").child(senderID + "\(NSUUID().uuidString).jpg").put(image!, metadata: nil){(metadata: FIRStorageMetadata?,   err: Error?) in
                
                if err != nil {
                    //TO DO inform the user that there was a problem uploading his image
                } else {
                    self.sendMediaMessage(senderID: senderID, senderName: senderName, url: String(describing: metadata!.downloadURL()!))
                    SVProgressHUD.dismiss()
                }
            }
        }
        
//        else {
//            //video
//            self.storageRef.child("videoStorage").child(senderID + "\(NSUUID().uuidString).jpg").putFile(video!, metadata: nil){(metadata: FIRStorageMetadata?, err: Error?) in
//
//                if err != nil {
//                    //TO DO inform the user that there was a problem uploading his video
//                } else {
//                    self.sendMediaMessage(senderID: senderID, senderName: senderName, url: String(describing: metadata!.downloadURL()!))
//                    
//                }
//            }
//        }
    }
    // ****** Sending media messages END ******
    
    
    
    
    
    
    
    
    
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
                    //print(profileImageUrl)
                    profileView.loadImageUsingCache(urlString: URL(string: profileImageUrl)!)
                    //set up in coming avatar
                    self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: profileView.image, diameter: 64)
                }
                containerView.addSubview(profileView)   //add image view to title view
                
                //ios9 constraint (image view stick to title view)
                profileView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
                profileView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
                profileView.widthAnchor.constraint(equalToConstant: 40).isActive = true
                profileView.heightAnchor.constraint(equalToConstant: 40).isActive = true
                
                
                //username label
                let nameLabel = UILabel()
                nameLabel.text = userprofile?.username?.components(separatedBy: " ")[0] //first name
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


