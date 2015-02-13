//
//  DateUser.swift
//  ElevenDates
//
//  Copyright (c) 2014 ElevenFifty. All rights reserved.
//

import Foundation

class DateUser : PFUser, PFSubclassing {
    override class func load() {
        self.registerSubclass()
    }
    
    var facebookId : String {
        get { return self["facebookId"] as String }
        set { self["facebookId"] = newValue }
    }
    
    var gender : String {
        get { return self["gender"] as? String ?? "male"}
        set { self["gender"] = newValue }
    }
    
    var age : Int {
        get { return self["age"] as? Int ?? 25 }
        set { self["age"] = newValue }
    }
    
    var firstName : String {
        get { return self["firstName"] as String }
        set { self["firstName"] = newValue }
    }
    
    var lastName : String {
        get { return self["lastName"] as String }
        set { self["lastName"] = newValue }
    }
    
    var name : String {
        get { return self["name"] as String }
        set { self["name"] = newValue }
    }
    
    var displayText : String {
        return "\(firstName), \(age)"
    }
    
    var image : PFFile {
        get { return self["image"] as PFFile }
        set { self["image"] = newValue }
    }
    
    var show : DatePreference {
        get { return DatePreference(rawValue: self["show"] as? Int ?? 2)! }
        set { self["show"] = newValue.rawValue }
    }
    
    var discoverable : Bool {
        get { return self["discoverable"] as Bool }
        set { self["discoverable"] = newValue }
    }
    
}
