//
//  ChatViewController.swift
//  ElevenDates
//
//  Copyright (c) 2014 ElevenFifty. All rights reserved.
//

import UIKit

class ChatViewController: JSQMessagesViewController {

    // to check for new messages
    var timer : NSTimer!
    // to prevent stomping on our own feet and double loading
    var isLoading = false
    
    // identifier for this room. scalable to mutiple users
    var chatroom = ""
    
    // currently only setup for two participants
    var currentUser : DateUser!
    var otherUser : DateUser!
    
    // Key - value collection of avatars so we don't double load too much
    var avatars = [String:JSQMessagesAvatarImage]()
    // Array of messages
    var messages = [JSQMessage]()
    // Key - value collection of users
    var users = [String:DateUser]()
    
    // chat bubbles for our conversation
    var outgoingBubbleImageView : JSQMessagesBubbleImage!
    var incomingBubbleImageView : JSQMessagesBubbleImage!
    
    override func viewDidLoad() {
            super.viewDidLoad()
        
        self.title = "Chat"
        
        // We create a chatroom for each user pair. it needs to be the same for both
        // so we always put smaller user id first
        self.senderId = DateUser.currentUser().objectId;
        self.chatroom = currentUser.objectId > otherUser.objectId ?
            "\(currentUser.objectId)-\(otherUser.objectId)" :
            "\(otherUser.objectId)-\(currentUser.objectId)"
        
        // setup chat bubbles
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        incomingBubbleImageView = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        
        // load messages
        isLoading = false;
        self.loadMessages()
        
        // We check for new messages every 5 seconds
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "loadMessages", userInfo: nil, repeats: true)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.collectionView.collectionViewLayout.springinessEnabled = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // when they leave this screen, stop checking for messages
        timer.invalidate()
    }

    func loadMessages() {
        if !isLoading {
            isLoading = true
            let message_last = messages.last

            // query to fetch messages
            let query = DateChat.query()
            query.whereKey("chatRoom", equalTo: chatroom)
            // time based pagination
            if message_last != nil {
                query.whereKey("createdAt", greaterThan: message_last?.date)
            }
            // we need this so we can get the sender's objectId for simplicity
            query.includeKey("sender")
            // show messages in order sent
            query.orderByAscending("createdAt")
            query.findObjectsInBackgroundWithBlock({ (objects, error) in
                if error == nil {
                    for object in objects {
                        // Go through each DateChat message and create a
                        // JSQMessage for display on this screen
                        let dateChat = object as DateChat
                        let message = JSQTextMessage(senderId: dateChat.sender.objectId, senderDisplayName: dateChat.sender.firstName, date: dateChat.createdAt, text: dateChat.chatText)
                    
                        self.messages.append(message)
                        
                        // just ensure we cache the user object for later
                        self.users[dateChat.sender.objectId] = dateChat.sender
                    }
                    if !objects.isEmpty {
                        self.finishReceivingMessage()
                    }
                }
                self.isLoading = false
            })
            
        }
        
    }
    
    // Mark - JSQMessagesViewController method overrides
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        // When they hit send. Save their message.
        let dateChat = DateChat()
        dateChat.chatRoom = chatroom
        dateChat.sender = DateUser.currentUser()
        dateChat.chatText = text
        
        dateChat.saveInBackgroundWithBlock { (succeeded, error) in
            if error == nil {
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.loadMessages()
            }
        }
        self.finishSendingMessage()
        
    }
    
    // Mark - JSQMessages CollectionView DataSource
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        // return message for current row
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = messages[indexPath.item]
        
        if message.senderId == self.senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        // show correct avatar for message sent
        
        let message = messages[indexPath.item]
        if self.avatars[message.senderId] == nil {
            var imageView = JSQMessagesAvatarImage(placeholder: UIImage(named: "profile"))
            self.avatars[message.senderId] = imageView
            
            let user = users[message.senderId]!
            user.image.getDataInBackgroundWithBlock { (data, error) in
                imageView.avatarImage = JSQMessagesAvatarImageFactory.circularAvatarImage(UIImage(data:data), withDiameter: 30)
                // Hack: For reload entire table now that avatar is downloaded
                self.collectionView.reloadData()
            }
        }

        return self.avatars[message.senderId];
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        // show date stamp every 3 records.
        if indexPath.item % 3 == 0
        {
            let message = messages[indexPath.item]
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        return nil;
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        // Show the name every once and a while
        let message = messages[indexPath.item]
        
        if message.senderId == self.senderId
        {
            return nil
        }
        
        if indexPath.item - 1 > 0
        {
            var previousMessage = messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId
            {
                return nil
            }
        }
        
        return NSAttributedString(string: otherUser.firstName)
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        return nil
    }

    // Mark - UICollectionView DataSource
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // Grab cell we are about to show
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as JSQMessagesCollectionViewCell
        
        // Customize it some
        let message = messages[indexPath.item]
        if message.senderId == self.senderId
        {
            cell.textView.textColor = UIColor.blackColor()
        }
        else
        {
            cell.textView.textColor = UIColor.whiteColor()
        }
        
        return cell;
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        // if we are going to show the date/time, give it some height
        if indexPath.item % 3 == 0
        {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0;
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        // more height logic
        let message = messages[indexPath.item]
        if message.senderId == self.senderId
        {
            return 0.0
        }
        
        if indexPath.item - 1 > 0
        {
            var previousMessage = messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId
            {
                return 0.0
            }
        }
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        // more height logic
        return 0.0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        println("tapped load earlier messages - need implementation")
    }
    
    
    
}
