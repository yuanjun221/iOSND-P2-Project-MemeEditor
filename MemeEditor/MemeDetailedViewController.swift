//
//  MemeDetailedViewController.swift
//  MemeEditor
//
//  Created by Jun.Yuan on 16/6/10.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import UIKit

// MARK: - ViewController Properties
class MemeDetailedViewController: UIViewController {
    var meme: Meme!
    var indexPath: NSIndexPath!
    var memeArrayCount: Int!
    
    @IBOutlet weak var memedImageView: UIImageView!
}


// MARK:- ViewController Lifecycle
extension MemeDetailedViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: #selector(deleteMeme))
        let editButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: #selector(editMeme))
        self.navigationItem.rightBarButtonItems = [deleteButton, editButton]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        memedImageView.image = meme.memedImage
        
        // auto pop to main screen if user add a new meme edited from detail view
        if (UIApplication.sharedApplication().delegate as! AppDelegate).memes.count != memeArrayCount {
            autoPopViewController()
        }
    }
    
    func autoPopViewController() {
        if let navigationController = self.navigationController {
            navigationController.popViewControllerAnimated(true)
        }
    }
}


// MARK: - View Touching Behavior
extension MemeDetailedViewController {
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let bar = navigationController!.navigationBar
        setAlphaForUIBar(bar, backgroundColorForImageView: memedImageView)
    }
    
    func setAlphaForUIBar(UIBar: UIView, backgroundColorForImageView imageView: UIImageView) {
        if UIBar.alpha == 0.0 {
            setUIView(UIBar, withAlpha: 1.0)
            setUIView(imageView, withBackgroundColor: UIColor.whiteColor())
        } else {
            setUIView(UIBar, withAlpha: 0.0)
            setUIView(imageView, withBackgroundColor: UIColor.blackColor())
        }
    }
}


// MARK:- Buttons Action
extension MemeDetailedViewController {
    func deleteMeme() {
        let titleText = "This memed image will be deleted."
        let alertController = UIAlertController(title: titleText, message: nil, preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title:"Delete Meme", style: .Destructive) { action in
            (UIApplication.sharedApplication().delegate as! AppDelegate).memes.removeAtIndex(self.indexPath.row)
            self.autoPopViewController()
        }
        let cancelAction = UIAlertAction(title:"Cancel", style: .Cancel, handler: nil)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func editMeme() {
        let editorVC = storyboard?.instantiateViewControllerWithIdentifier(memeEditorViewControllerID) as! MemeEditorViewController
        editorVC.pushedInMeme = meme
        presentViewController(editorVC, animated: true, completion: nil)
    }
}
