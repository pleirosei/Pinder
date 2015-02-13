//
//  MockUserViewController.swift
//  ElevenDates
//
//  Copyright (c) 2014 ElevenFifty. All rights reserved.
//

import UIKit

// This view controller is only here to let me seed data.
class MockUserViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var age: UITextField!
    @IBOutlet weak var isMale: UISwitch!
    
    var uploadImage : NSData?
    var picker : UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func profileTapped(sender: UIButton) {
        picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        presentViewController(picker, animated: true, completion: nil)
    }

    
    @IBAction func addTapped(sender: UIButton) {
        var newUser = DateUser()
        
        newUser.username = randomString(10)
        newUser.password = "12345"
        newUser.firstName = firstName.text
        newUser.lastName = lastName.text
        newUser.name = "\(newUser.firstName) \(newUser.lastName)"
        newUser.discoverable = true
        
        if let ageInt = age.text.toInt() {
            newUser.age = ageInt
        }
        
        newUser.gender = isMale.on ? "male" : "female"
        
        if uploadImage != nil {
            newUser.image = PFFile(name: "image.jpg", data: uploadImage!)
        }
        
        newUser.signUpInBackgroundWithBlock { (worked, error) -> Void in
            if worked {
                println("Saved")
            } else {
                println("Failed")
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        var image = info["UIImagePickerControllerOriginalImage"] as UIImage
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        profileButton.setImage(image, forState: UIControlState.Normal)
        uploadImage = compressImage(image)
        
    }
    
    
    func compressImage(image:UIImage) -> NSData {
        // Drops from 2MB -> 64 KB!!!
        
        var actualHeight : CGFloat = image.size.height
        var actualWidth : CGFloat = image.size.width
        var maxHeight : CGFloat = 1136.0
        var maxWidth : CGFloat = 640.0
        var imgRatio : CGFloat = actualWidth/actualHeight
        var maxRatio : CGFloat = maxWidth/maxHeight
        var compressionQuality : CGFloat = 0.5
        
        if (actualHeight > maxHeight || actualWidth > maxWidth){
            if(imgRatio < maxRatio){
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight;
                actualWidth = imgRatio * actualWidth;
                actualHeight = maxHeight;
            }
            else if(imgRatio > maxRatio){
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth;
                actualHeight = imgRatio * actualHeight;
                actualWidth = maxWidth;
            }
            else{
                actualHeight = maxHeight;
                actualWidth = maxWidth;
            }
        }
        
        var rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
        UIGraphicsBeginImageContext(rect.size);
        image.drawInRect(rect)
        var img = UIGraphicsGetImageFromCurrentImageContext();
        let imageData = UIImageJPEGRepresentation(img, compressionQuality);
        UIGraphicsEndImageContext();
        
        return imageData;
    }
    
    
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    
    func randomString(len:Int) -> String {
        var randomString = ""
        let letterArray = Array(letters)
    
        for num in 0...len {
            var lettersLen = UInt32(letterArray.count)
            var index = Int(arc4random_uniform(lettersLen) % lettersLen)
            var randomLetter = letterArray[index]
            randomString.append(randomLetter)
        }
        
        return randomString;
    }
    
}
