//
//  ProfileViewController.swift
//  ElevenDates
//
//  Copyright (c) 2014 ElevenFifty. All rights reserved.
//

import UIKit

class ProfileViewController: UITableViewController {
    
    var currentUser = DateUser.currentUser()

    // Mark: Interface builder outlets
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var genderSegment: UISegmentedControl!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var discoverableSwitch: UISwitch!
    @IBOutlet weak var ageSlider: UISlider!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var showButton: UIButton!
    
    // Mark: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImage.layer.cornerRadius = 8.0
        userImage.clipsToBounds = true
        
        updateUI()

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Save the data
        currentUser.saveInBackground()
    }

    // Mark: Actions
    @IBAction func discoverableChanged(sender: UISwitch) {
        currentUser.discoverable = sender.on
        
    }

    @IBAction func ageChanged(sender: UISlider) {
        let age = Int(sender.value)
        currentUser.age = age
        updateUI()
        
    }
    
    @IBAction func genderChanged(sender: UISegmentedControl) {
        currentUser.gender = sender.selectedSegmentIndex == 0 ? "male" : "female"
    }
    
    @IBAction func showMenOnly(segue:UIStoryboardSegue)
    {
        currentUser.show = DatePreference.MaleOnly
    }
    
    @IBAction func showWomanOnly(segue:UIStoryboardSegue)
    {
        currentUser.show = DatePreference.FemaleOnly
    }
    
    @IBAction func showBoth(segue:UIStoryboardSegue)
    {
        currentUser.show = DatePreference.Both
    }
    
    func updateUI() {
        // download their avatar
        currentUser.image.getDataInBackgroundWithBlock { (data, error) -> Void in
            if data != nil && error == nil {
                self.userImage.image = UIImage(data: data)
            }
        }
        
        // show their name
        name.text = currentUser.firstName
        
        // show their gender
        genderSegment.selectedSegmentIndex = currentUser.gender == "male" ? 0 : 1
        
        // if they are visible
        discoverableSwitch.on = currentUser.discoverable
        
        // show their age
        ageLabel.text = "\(currentUser.age)"
        
        // let them pick their age
        ageSlider.value = Float(currentUser.age)
        
        // and show their preference
        switch currentUser.show {
        case .MaleOnly:
            showButton.setTitle("Men Only", forState: UIControlState.Normal)
        case .FemaleOnly:
            showButton.setTitle("Women Only", forState: UIControlState.Normal)
        case .Both:
            showButton.setTitle("Men and Women", forState: UIControlState.Normal)
        }
    }
}
