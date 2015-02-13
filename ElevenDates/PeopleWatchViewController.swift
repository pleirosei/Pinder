//
//  ViewController.swift
//  ElevenDates
//
//  Copyright (c) 2014 ElevenFifty. All rights reserved.
//

import UIKit

class PeopleWatchViewController: UIViewController,UIGestureRecognizerDelegate {
    
    // Mark: Interface Builder Outlets
    @IBOutlet weak var userCardView: UIView!
    @IBOutlet weak var userNameAge: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var failImage: UIImageView!
    @IBOutlet weak var passImage: UIImageView!
    
    // Preview Card
    @IBOutlet weak var previewUserCardView: UIView!
    @IBOutlet weak var previewUserNameAge: UILabel!
    @IBOutlet weak var previewUserImage: UIImageView!
    
    // Shorthand to our date store
    private var dateStore = DateStore.sharedNoteStore
    // Where the card starts on the screen
    private var cardStartCenter = CGPointZero
    // bucket of who they are going to see
    private var potentialMatches : [DateUser]!
    // pagination: how many records do we skip, when we call get more
    private var skip = 0
    // the index in the array of the preview item (under visible card)
    private var nextPreview = 0
    // foreground card user
    private var currentPotential : DateUser?
    // preview card user
    private var nextPotential : DateUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // clear out placeholder data in our storyboard
        
        // setup the drag desture recognizer
        let pan = UIPanGestureRecognizer(target: self, action: "moveUserCard:")
        pan.delegate = self
        self.userCardView.addGestureRecognizer(pan)
        // round out the corners of the cards
        userCardView.layer.cornerRadius = 8.0
        userCardView.clipsToBounds = true
        
        previewUserCardView.layer.cornerRadius = 8.0
        previewUserCardView.clipsToBounds = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // just log the starting location of the card
        cardStartCenter = userCardView.center
        
        loadCards(true)
    }
    
    func loading() {
        userImage.image = nil
        userNameAge.text = ""
        previewUserImage.image = nil
        previewUserNameAge.text = ""
    }
    
    func loadCards(reset:Bool) {
        if reset {
            loading()
            skip = 0
        }
        
        // call store to get cards
        dateStore.getPotentials(skip: skip) { (potentialReturn) -> () in
            if let potentials = potentialReturn {
                // update pagination index
                self.skip += potentials.count
                
                // save the results
                self.potentialMatches = potentials
                
                // start at the beginning again (we just replaced array)
                self.nextPreview = 0
                
                // handle first load
                if reset {
                    self.firstLoad()
                }
            }
        }
    }
    
    @IBAction func nopeTapped(sender: UIButton) {
        doNo()
    }
    
    @IBAction func infoTapped(sender: UIButton) {
        // TODO: You could add your own public user info screen here
    }
    
    @IBAction func yesTapped(sender: UIButton) {
        doYes()
    }
    
    func doYes() {
        // give up if there is nothing to work with
        if currentPotential == nil { return }
        
        // Save Data
        dateStore.likePerson(currentPotential!)
        
        // Stamp it yes
        self.passImage.alpha = 1
        // Off screen to the right
        let offRight = CGPointMake(self.view.frame.size.width + self.userCardView.frame.width, 0)
        
        UIView.animateWithDuration(0.6, animations: { () -> Void in
            self.userCardView.center = offRight
            }) { (finished) in
                if finished {
                    self.nextUserCard()
                }
        }
    }
    
    func doNo() {
        // give up if there is nothing to work with
        if currentPotential == nil { return }
        // Save Data
        dateStore.nopeUser(currentPotential!)
        // Stamp it no
        self.failImage.alpha = 1
        // Off screen to the left
        let offLeft = CGPointMake(-(self.view.frame.size.width + self.userCardView.frame.width), 0)
        
        UIView.animateWithDuration(0.6, animations: { () -> Void in
            self.userCardView.center = offLeft
            }) { (finished) in
                if finished {
                    self.nextUserCard()
                }
        }
    }
    
    func firstLoad() {
        // The first time they come to this screen we have to get
        // and display not only the preview card, but the visible
        // card as well.  On pagination, we simply replace the
        // card behind the visible card.
        
        
        // give up if there is nothing to work with
        if potentialMatches.isEmpty { return }
        
        // grab first record
        currentPotential = potentialMatches.first
        if let currentUser = currentPotential {
            // show name / age
            userNameAge.text = currentUser.displayText
            // and download the image
            currentUser.image.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if error == nil && data != nil {
                    self.userImage.image = UIImage(data: data)
                }
            })
        }
        // increment our preview and then load it
        nextPreview = 1
        loadPreview()
        
    }
    
    func loadPreview() {
        if nextPreview >= potentialMatches.count {
            // End of the road
            nextPotential = nil
            previewUserImage.image = UIImage(named: "closed")
            return
        }
        
        // Grab next potential
        nextPotential = potentialMatches[nextPreview]
        
        if let previewUser = nextPotential {
            // show name / age
            previewUserNameAge.text = previewUser.displayText
            // and download the image
            previewUser.image.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if error == nil && data != nil {
                    self.previewUserImage.image = UIImage(data: data)
                }
            })
        }
        
        // set ourselves up for the next preview
        if ++nextPreview >= potentialMatches.count {
            // but if we reached the end of potentials, get more
            loadCards(false)
        }
    }
    
    func nextUserCard()
    {
        // Assume the current user card is off screen.
        
        // 1: Replace the contents of the current user card with the preview card
        currentPotential = nextPotential
        userImage.image = previewUserImage.image
        userNameAge.text = previewUserNameAge.text
        
        // 2: Reset the current user card location and apperance
        userCardView.center = cardStartCenter
        failImage.alpha = 0
        passImage.alpha = 0
        // 3: Erase the contents of the preview card (until they are loaded)
        previewUserImage.image = nil
        previewUserNameAge.text = ""
        // 4: Fetch the next preview user card
        loadPreview()
    }
    
    func moveUserCard(sender:UIGestureRecognizer) {
        // just showing a nested function
        func between < T: Comparable> (item:T, minItem:T, maxItem:T) -> T {
            if item > minItem {
                return min(maxItem, item)
            } else {
                return max(minItem, item)
            }
        }
        
        if currentPotential == nil { return }
        
        let panRecognizer = sender as UIPanGestureRecognizer
        // Where is it now
        let currentPoint = userCardView.center
        
        // Where is it going to be
        let translation = panRecognizer.translationInView(userCardView.superview!)
        // How far did it move
        let delta = currentPoint.x - cardStartCenter.x
        
        // How visible should the stamps be
        let alpha = between(abs(delta), -75.0, 75.0) / 75.0
        
        switch panRecognizer.state {
        case .Changed:
            userCardView.center = CGPoint(x: currentPoint.x + translation.x, y: currentPoint.y + translation.y)
            
            if delta > 0 {
                failImage.alpha = 0
                passImage.alpha = alpha
            } else {
                failImage.alpha = alpha
                passImage.alpha = 0
            }
            
            panRecognizer.setTranslation(CGPointZero, inView: userCardView.superview!)
            
        case .Ended:
            
            if alpha < 1.0 {
                // bounce back
                UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: nil, animations: { () -> Void in
                    self.userCardView.center = self.cardStartCenter
                    self.failImage.alpha = 0
                    self.passImage.alpha = 0
                    
                    }, completion: nil)
            } else {
                // toss view off the screen
                if delta > 0 {
                    doYes()
                } else {
                    doNo()
                }
            }
            
        default:
            break
        }
    }
    
}

