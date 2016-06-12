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

    @IBOutlet var memeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addMeme))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        memeTableView.reloadData()
    }
    
    func addMeme() {
        let memeEditorVC = storyboard?.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let detailedVC = segue.destinationViewController as! MemeDetailedViewController
        detailedVC.hidesBottomBarWhenPushed = true
        let indexPath = memeTableView.indexPathForSelectedRow!
        detailedVC.meme = memes[indexPath.row]
        detailedVC.indexPath = indexPath
    }
}
