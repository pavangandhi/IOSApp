//
//  SelectFriendsViewController.swift
//  Blink
//
//  Created by Remi Robert on 24/09/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

import UIKit
import Parse
import ReactiveCocoa

class SelectFriendsViewController: UIViewController {

    @IBOutlet var tableViewFriend: UITableView!
    @IBOutlet var tableViewPlace: UITableView!
    @IBOutlet var selectionLabel: UILabel!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var segmentSelection: UISegmentedControl!
    var friends = Array<PFObject>()
    var friendsSelected = Array<PFObject>()
    var placesCellData = ["Nearby (<25km)", "Far far away"]
    var placeSelected: String?
    
    @IBAction func dismissSelection(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func initTableView(tableView: UITableView) {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.registerNib(UINib(nibName: "SelectTableViewCell", bundle: nil), forCellReuseIdentifier: "selectCell")
        tableView.allowsMultipleSelection = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableView(tableViewFriend)
        initTableView(tableViewPlace)
        tableViewPlace.hidden = true
        
        Friend.friends(PFCachePolicy.CacheThenNetwork).subscribeNext({ (next: AnyObject!) -> Void in
            
            if let friends = next as? [PFObject] {
                self.friends = friends
                self.tableViewFriend.reloadData()
            }
            }, error: { (error: NSError!) -> Void in
                print("error to get friends list : \(error)")
            }) { () -> Void in
        }
        
        segmentSelection.rac_signalForControlEvents(UIControlEvents.ValueChanged).subscribeNext { (_) -> Void in
            if self.segmentSelection.selectedSegmentIndex == 0 {
                self.tableViewPlace.alpha = 0
                self.tableViewFriend.alpha = 1
            }
            else {
                self.tableViewFriend.alpha = 0
                self.tableViewPlace.alpha = 1
            }
        }
    }
}

//MARK:
//MARK: UITableView dataSource
extension SelectFriendsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return friends.count
        }
        return placesCellData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView.tag == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("selectCell") as! SelectTableViewCell
            
            let currentFriend = friends[indexPath.row]
            if let username = currentFriend["trueUsername"] as? String {
                cell.initCell(username)
            }
            
            if friendsSelected.contains(currentFriend) {
                cell.selectCell()
            }
            else {
                cell.deselectCell()
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("selectCell") as! SelectTableViewCell
            
            cell.initCell(placesCellData[indexPath.row])
            cell.deselectCell()
            if let selectedPlace = placeSelected {
                if selectedPlace == placesCellData[indexPath.row] {
                    cell.selectCell()
                }
            }
            return cell
        }
    }
}

//MARK:
//MARK: UITableView delegate
extension SelectFriendsViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.tag == 0 {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? SelectTableViewCell {
                cell.deselectCell()
                removeFriendSelected(friends[indexPath.row])
            }
        }
        else {
            placeSelected = nil
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.tag == 0 {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? SelectTableViewCell {
                cell.selectCell()
                addFriendSelected(friends[indexPath.row])
            }
        }
        else {
            placeSelected = placesCellData[indexPath.row]
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
}

//MARK:
//MARK: friend selection management
extension SelectFriendsViewController {
    
    func updateDisplayLabelSelected() {
        self.selectionLabel.text = "\(friendsSelected.count) selected"
    }
    
    func removeFriendSelected(friend: PFObject) {
        for var index = 0; index < friendsSelected.count; index++ {
            if friendsSelected[index] == friend {
                friendsSelected.removeAtIndex(index)
                updateDisplayLabelSelected()
                return
            }
        }
    }
    
    func addFriendSelected(friend: PFObject) {
        self.friendsSelected.append(friend)
        updateDisplayLabelSelected()
    }
}
