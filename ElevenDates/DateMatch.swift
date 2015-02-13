//
//  DateMatch.swift
//  ElevenDates
//
//  Copyright (c) 2014 ElevenFifty. All rights reserved.
//

import Foundation

class DateMatch : PFObject, PFSubclassing
{
    override class func load() {
        self.registerSubclass()
    }
    class func parseClassName() -> String! {
        return "DateMatch"
    }
    override init() {
        super.init()
    }
    
    var currentUser : DateUser {
        get { return self["currentUser"] as DateUser }
        set { self["currentUser"] = newValue }
    }
    
    var targetUser : DateUser {
        get { return self["targetUser"] as DateUser }
        set { self["targetUser"] = newValue }
    }
    
    var isMatch : Bool {
        get { return self["isMatch"] as Bool }
        set { self["isMatch"] = newValue }
    }
    
    var mutualMatch : Bool {
        get { return self["mutualMatch"] as Bool }
        set { self["mutualMatch"] = newValue }
    }
}