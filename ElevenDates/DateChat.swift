//
//  DateChat.swift
//  ElevenDates
//
//  Copyright (c) 2014 ElevenFifty. All rights reserved.
//

import Foundation

class DateChat : PFObject, PFSubclassing
{
    override class func load() {
        self.registerSubclass()
    }
    class func parseClassName() -> String! {
        return "DateChat"
    }
    override init() {
        super.init()
    }
    
    var chatRoom : String {
        get { return self["chatRoom"] as String }
        set { self["chatRoom"] = newValue }
    }
    
    var sender : DateUser {
        get { return self["sender"] as DateUser }
        set { self["sender"] = newValue }
    }
    
    var chatText : String {
        get { return self["chatText"] as String }
        set { self["chatText"] = newValue }
    }
}