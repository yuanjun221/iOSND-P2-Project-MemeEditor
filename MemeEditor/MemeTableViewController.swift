//
//  MemeTableViewController.swift
//  MemeEditor
//
//  Created by Jun.Yuan on 16/6/10.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import UIKit

// MARK:- View Controller Properties
class MemeTableViewController: UIViewController {
    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }
    
    @IBOutlet var memeTableView: UITableView!
    
    private var indexPathToTransmit: NSIndexPath {
        return memeTableView.indexPathForSelectedRow!
    }

    private var editButton: UIBarButtonItem!
}


// MARK:- View Controller Lifecycle
extension MemeTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: #selector(toggleEditButton))
        editButton = navigationItem.leftBarButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addMeme))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        memeTableView.reloadData()
        enableButton(editButton, withMemesCount: memes.count)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        setSegue(segue, withMemes: memes, indexPath: indexPathToTransmit)
    }
}


// MARK:- Buttons Action
extension MemeTableViewController {
    // Buttons Action
    func toggleEditButton() {
        setTableViewWithEdtingStatus(memeTableView.editing)
    }
    
    func addMeme() {
        let memeEditorVC = storyboard?.instantiateViewControllerWithIdentifier(memeEditorViewControllerID) as! MemeEditorViewController
        presentViewController(memeEditorVC, animated: true, completion: nil)
    }
    
    // Helper Function
    func setTableViewWithEdtingStatus(isEditing: Bool) {
        editButton.title = ""      // make the button title transition more smoothly
        editButton.title = isEditing ? "Edit" : "Done"
        memeTableView.setEditing(!isEditing, animated: true)
        setUIView(tabBarController!.tabBar, withAlpha: CGFloat(isEditing ? 1 : 0))
        navigationItem.rightBarButtonItem = isEditing ? UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addMeme)) : nil
    }
}


// MARK:- TableView Data Source
extension MemeTableViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let meme = memes[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("memeTableCell") as! MemeTableViewCell
        cell.memedImage.image = meme.memedImage
        cell.topTextLabel.text = meme.topText
        cell.bottomTextLabel.text = meme.bottomText
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).memes.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        moveItemAtIndex(fromIndex: sourceIndexPath.row, toIndex: destinationIndexPath.row)
    }
    
    func moveItemAtIndex(fromIndex start: Int, toIndex end: Int) {
        if start == end {
            return
        }
        let selectedMeme = memes[start]
        (UIApplication.sharedApplication().delegate as! AppDelegate).memes.removeAtIndex(start)
        (UIApplication.sharedApplication().delegate as! AppDelegate).memes.insert(selectedMeme, atIndex: end)
    }
}
