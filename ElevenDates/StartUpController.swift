//
//  RootViewController.swift
//  ElevenDates
//
//  Copyright (c) 2014 ElevenFifty. All rights reserved.
//

import Foundation
import Alamofire
import AssetsLibrary

class StartUpController : NSObject, PFLogInViewControllerDelegate
{
    var window : UIWindow!
    
    init(window:UIWindow)
    {
        super.init()
        // this is coming from app delegate
        self.window = window
        
        // if the user is signed in,
        if DateUser.currentUser() != nil {
            // update the storyboard
            showStoryboard()
            // Optional: Refresh their in-app profile from facebook
            updateProfileFromFacebook()
        } else {
            // show the login screen
            showLogin()
        }
        
    }
    
    func showStoryboard()
    {
        // find the storyboard
        var storyBoard = UIStoryboard(name: "Main", bundle: nil)
        // get storyboard entry point
        var start = storyBoard.instantiateInitialViewController() as UIViewController
        // start storyboard
        window?.rootViewController = start
        window?.makeKeyAndVisible()
    }
    
    func showLogin() {
        // Create a login view controller
        var loginViewController = PFLogInViewController()
        loginViewController.delegate = self
        loginViewController.fields = PFLogInFields.Facebook;
        loginViewController.facebookPermissions = ["user_about_me"];
        
        // at least put our logo on it, a full screen wallpaper would be better
        var logo = UIImage(named: "Logo")
        loginViewController.logInView.logo = UIImageView(image: logo)
        
        // start it
        window?.rootViewController = loginViewController
        window?.makeKeyAndVisible()
    }
    
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController!) {
        println("Cancelled login!")
    }
    
    func logInViewController(logInController: PFLogInViewController!, didLogInUser user: PFUser!) {
        println("Login successful!")
        // you could choose to only update their profile from facebook on
        // account creation with this method
        if user.isNew {
            updateProfileFromFacebook()
        }
        // show storyboard now they are logged in
        showStoryboard()
    }
    
    func logInViewController(logInController: PFLogInViewController!, didFailToLogInWithError error: NSError!) {
        println("Login failed \(error)")
    }
    
    func updateProfileFromFacebook()
    {
        // use a facebook request to get information about the user
        
        var request = FBRequest.requestForMe()
        request.startWithCompletionHandler { (connection, result, err) in
            if err == nil {
                println("Updating profile from facebook")
                var currentUser = DateUser.currentUser()
                
                var userData = result as NSDictionary
                currentUser.facebookId = userData["id"] as String
                currentUser.firstName = userData["first_name"] as String
                currentUser.lastName = userData["last_name"] as String
                currentUser.name = userData["name"] as String
                currentUser.discoverable = true
                currentUser.saveInBackground()
                
                self.updateFacebookImage()
            }
            
        }
    }
    
    func updateFacebookImage()
    {
        // Download the users profile photo into our app
        var currentUser = DateUser.currentUser()
        
//        https://graph.facebook.com/10204783537686030/picture?type=square&width=600&height=600
        var pictureURL = "https://graph.facebook.com/\(currentUser.facebookId)/picture?type=square&width=600&height=600"
        
        
        // We use alamo fire because NSURLConnection does not handle redirects automatically. And it is way better in every way
        Alamofire.request(.GET, pictureURL).response {
            (request, response, data, error) in
            
            if error == nil && data != nil {
                println("Updating profile image from facebook")
                currentUser.image = PFFile(name: "image.jpg", data: data as NSData)
                currentUser.saveInBackground()
            } else {
                println("Failed to Updating profile image from facebook: \(error))")
            }
            
        }
        
    }
    
    
}