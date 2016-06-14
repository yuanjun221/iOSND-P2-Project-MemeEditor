//
//  MemeTableViewController.swift
//  MemeEditor
//
//  Created by Jun.Yuan on 16/6/10.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import UIKit

class MemeTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }
    
    private var indexPathToTransmit: NSIndexPath {
        return memeTableView.indexPathForSelectedRow!
    }
 
    @IBOutlet var memeTableView: UITableView!
    
    private var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: #selector(toggleEditButton))
        editButton = self.navigationItem.leftBarButtonItem
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addMeme))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        memeTableView.reloadData()
        enableButton(editButton, withMemesCount: memes.count)
    }
        
    func toggleEditButton() {
        setTableViewWithEdtingStatus(memeTableView.editing)
    }
    
    func setTableViewWithEdtingStatus(isEditing: Bool) {
        let barButtonTitle = isEditing ? "Edit" : "Done"
        let alpha = isEditing ? 1 : 0
        editButton.title = ""      // make the button title transition more smoothly
        editButton.title = barButtonTitle
        memeTableView.setEditing(!isEditing, animated: true)
        setUIView(tabBarController!.tabBar, withAlpha: CGFloat(alpha))
        navigationItem.rightBarButtonItem = isEditing ? UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addMeme)) : nil
    }
    
    func addMeme() {
        let memeEditorVC = storyboard?.instantiateViewControllerWithIdentifier(memeEditorViewControllerID) as! MemeEditorViewController
        presentViewController(memeEditorVC, animated: true, completion: nil)
    }

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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        setSegue(segue, withMemes: memes, indexPath: indexPathToTransmit)
    }
}
