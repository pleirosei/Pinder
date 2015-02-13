//
//  DateStore.swift
//  ElevenDates
//
//  Copyright (c) 2014 ElevenFifty. All rights reserved.
//

import Foundation

class DateStore {
    // MARK: Singleton Pattern
    class var sharedNoteStore : DateStore {
    struct Static {
        static let instance : DateStore = DateStore()
        }
        return Static.instance
    }
    
    // Private init to force usage of singleton
    private init() {
    }
    
    // Mark: Functions for liking / noping a person
    func likePerson(user:DateUser) {
        matchUser(DateUser.currentUser(), user2: user, isMatch: true)
    }
    
    func nopeUser(user:DateUser) {
        matchUser(DateUser.currentUser(), user2: user, isMatch: false)
    }
    
    private func matchUser(user1:DateUser, user2:DateUser, isMatch:Bool) {
        var match = DateMatch()
        match.currentUser = user1
        match.targetUser = user2
        match.isMatch = isMatch
        
        checkMatch(match)
    }
    
    private func checkMatch(theMatch:DateMatch) {
        if theMatch.isMatch
        {
            // check mutual match
            var mutalMatch = DateMatch.query()
            mutalMatch.whereKey("currentUser", equalTo:theMatch.targetUser)
            mutalMatch.whereKey("targetUser", equalTo:theMatch.currentUser)
            mutalMatch.whereKey("isMatch", equalTo:true)
            
            mutalMatch.getFirstObjectInBackgroundWithBlock { (match, error) -> Void in
                var mutualMatch = false
                if let foundMatch = match as? DateMatch {
                    // Update the other person's record to be a mutual match
                    mutualMatch = true
                    foundMatch.mutualMatch = mutualMatch
                    foundMatch.saveInBackground()
                }
                self.updateOrInsertMatch(theMatch, mutualMatch: mutualMatch)
            }
        } else { // if they don't like the other user, don't bother checking for a mutual match
            updateOrInsertMatch(theMatch, mutualMatch: false)
        }
    }
    
    private func updateOrInsertMatch(theMatch:DateMatch, mutualMatch:Bool) {
        // This actually does the save, so...
        // example: likePerson -> matchUser -> checkMatch -> [You are here]
        var query = DateMatch.query()
        query.whereKey("currentUser", equalTo:theMatch.currentUser)
        query.whereKey("targetUser", equalTo:theMatch.targetUser)
        query.getFirstObjectInBackgroundWithBlock { (match, error) -> Void in
            if let foundMatch = match as? DateMatch {
                foundMatch.isMatch = theMatch.isMatch
                foundMatch.mutualMatch = mutualMatch
                foundMatch.saveInBackground()
            } else {
                theMatch.mutualMatch = mutualMatch
                theMatch.saveInBackground()
            }
        }
    }
    
    func getPotentials(skip:Int = 0, completion:( ([DateUser]?) -> ()) ) {
        // Get the current user
        var currentUser = DateUser.currentUser()
        
        var query = DateUser.query()
        // pagination
        query.skip = skip
        
        // We want to find users who match the dating preference
        switch currentUser.show
        {
        case .Both:
            break // do nothing
        case .FemaleOnly:
            query.whereKey("gender", equalTo: "female")
        case .MaleOnly:
            query.whereKey("gender", equalTo: "male")
        }
        
        // Exclude ourselves from the results
        query.whereKey("objectId", notEqualTo: currentUser.objectId)
        
        // Only show those who have not opted out
        query.whereKey("discoverable", equalTo: true)
        
        query.findObjectsInBackgroundWithBlock { (users, err) -> Void in
            completion(users as? [DateUser])
        }
    }
}