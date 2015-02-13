//
//  MatchTableViewController.swift
//  ElevenDates
//
//  Copyright (c) 2014 ElevenFifty. All rights reserved.
//

import UIKit

class MatchTableViewController : PFQueryTableViewController,UIGestureRecognizerDelegate {
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        self.parseClassName = DateMatch.parseClassName()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        self.parseClassName = DateMatch.parseClassName()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func queryForTable() -> PFQuery! {
        var query : PFQuery!
        
        // show people we are a mutual match with
        query = DateMatch.query()
        query.whereKey("currentUser", equalTo: DateUser.currentUser())
        query.whereKey("mutualMatch", equalTo: true)
        query.includeKey("targetUser")
        
        return query
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!, object: PFObject!) -> PFTableViewCell! {
        
        var cell = tableView.dequeueReusableHeaderFooterViewWithIdentifier("PFTableViewCell") as? PFTableViewCell
        
        if cell == nil {
            cell = PFTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "PFTableViewCell")
            // round off images
            cell?.imageView.layer.cornerRadius = 8.0
            cell?.imageView.clipsToBounds = true
        }
        
        // fetch and show our match
        var match = object as DateMatch
        
        cell?.textLabel?.text = match.targetUser.displayText
        cell?.imageView?.file = match.targetUser.image
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // if we tap a match, display a chat window
        var match = objectAtIndexPath(indexPath) as DateMatch
        var chatVC = ChatViewController()
        chatVC.currentUser = DateUser.currentUser()
        chatVC.otherUser = match.targetUser
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
}
