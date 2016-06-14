//
//  MemeCollectionViewController.swift
//  MemeEditor
//
//  Created by Jun.Yuan on 16/6/10.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import UIKit

class MemeCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }

    private var indexPathToTransmit: NSIndexPath {
        return memeCollectionView.indexPathsForSelectedItems()![0]
    }

    @IBOutlet var memeCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    private var selectButton: UIBarButtonItem!
    
    private var selected = false
    
    private var selectedMemes = [Meme]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Select", style: .Plain, target: self, action: #selector(toggleSelectButton))
        selectButton = self.navigationItem.leftBarButtonItem
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addMeme))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        memeCollectionView.reloadData()
        enableButton(selectButton, withMemesCount: memes.count)
    }
    
    func toggleSelectButton() {
        if selected {
            selected = false
            selectButton.title = ""
            selectButton.title = "Select"
            if let indexPaths = memeCollectionView.indexPathsForSelectedItems() {
                for indexPath in indexPaths {
                    let selectedCell = memeCollectionView.cellForItemAtIndexPath(indexPath) as! MemeCollectionViewCell
                    selectedCell.checkMark.image = nil
                    memeCollectionView.deselectItemAtIndexPath(indexPath, animated: false)
                }
                selectedMemes.removeAll()
            }
            memeCollectionView.allowsMultipleSelection = false
            setUIView(tabBarController!.tabBar, withAlpha: 1)
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addMeme))
            selectButton.enabled = !memes.isEmpty
        } else {
            selected = true
            selectButton.title = ""
            selectButton.title = "Cancel"
            memeCollectionView.allowsMultipleSelection = true
            setUIView(tabBarController!.tabBar, withAlpha: 0)
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action:#selector(deleteSelectedItem))
            navigationItem.rightBarButtonItem?.enabled = false
        }
    }
    
    func deleteSelectedItem() {
        let titleText = "Selected items will be deleted."
        let alertController = UIAlertController(title: titleText, message: nil, preferredStyle: .ActionSheet)
        let resetAction = UIAlertAction(title:"Delete \(selectedMemes.count) items", style: .Destructive) { action in
            for meme in self.selectedMemes {
                let index = self.memes.indexOf(meme)!
                (UIApplication.sharedApplication().delegate as! AppDelegate).memes.removeAtIndex(index)
            }
            self.autoEnableTrashButton()
            self.toggleSelectButton()
            self.memeCollectionView.reloadData()
        }
        let cancelAction = UIAlertAction(title:"Cancel", style: .Cancel, handler: nil)
        alertController.addAction(resetAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func addMeme() {
        let memeEditorVC = storyboard?.instantiateViewControllerWithIdentifier(memeEditorViewControllerID) as! MemeEditorViewController
        presentViewController(memeEditorVC, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let meme = memes[indexPath.row]
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("memeCollectionCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        cell.memedImage.image = meme.memedImage
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if !selected {
            performSegueWithIdentifier(segueFromCollectionToEditorID, sender: self)
        } else {
            let selectedCell = memeCollectionView.cellForItemAtIndexPath(indexPath) as! MemeCollectionViewCell
            selectedCell.checkMark.image = UIImage(named: "checkMark")
            let selectedMeme = memes[indexPath.row]
            selectedMemes.append(selectedMeme)
            autoEnableTrashButton()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = memeCollectionView.cellForItemAtIndexPath(indexPath) as! MemeCollectionViewCell
        selectedCell.checkMark.image = nil
        
        let deSeleteMeme = memes[indexPath.row]
        let index = selectedMemes.indexOf(deSeleteMeme)!
        selectedMemes.removeAtIndex(index)
        autoEnableTrashButton()
    }
    
    func autoEnableTrashButton() {
        navigationItem.rightBarButtonItem?.enabled = !selectedMemes.isEmpty
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return getCellSize()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        let size = getCellSize()
        flowLayout.itemSize = size
        flowLayout.invalidateLayout()
    }
    
    func getCellSize() -> CGSize {
        let width = self.view.frame.size.width
        
        let dimension: CGFloat!
        let size: CGSize!
        
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        
        if orientation.isPortrait {
            dimension = (width - 3.0) / 4.0
            size = CGSizeMake(dimension, dimension)
        } else {
            dimension = (width - 6.0) / 7.0
            size = CGSizeMake(dimension, dimension)
        }
        return size
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        setSegue(segue, withMemes: memes, indexPath: indexPathToTransmit)
    }
}
