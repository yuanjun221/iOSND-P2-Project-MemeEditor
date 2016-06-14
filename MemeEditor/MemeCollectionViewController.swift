//
//  MemeCollectionViewController.swift
//  MemeEditor
//
//  Created by Jun.Yuan on 16/6/10.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import UIKit

// MARK:- View Controller Properties
class MemeCollectionViewController: UIViewController {
    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }

    private var indexPathToTransmit: NSIndexPath {
        return memeCollectionView.indexPathsForSelectedItems()![0]
    }

    @IBOutlet var memeCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    private var selectButton: UIBarButtonItem!
    
    private var isSelecting = false
    private var selectedMemes = [Meme]()
}


// MARK:- View Controller Lifecycle
extension MemeCollectionViewController {
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        setSegue(segue, withMemes: memes, indexPath: indexPathToTransmit)
    }
}


// MARK:- Buttons Action
extension MemeCollectionViewController {
    // Buttons Action
    func toggleSelectButton() {
        setCollectionViewWithSelectingStatus(isSelecting)
    }
    
    func addMeme() {
        let memeEditorVC = storyboard?.instantiateViewControllerWithIdentifier(memeEditorViewControllerID) as! MemeEditorViewController
        presentViewController(memeEditorVC, animated: true, completion: nil)
    }
    
    func deleteSelectedItems() {
        let titleText = "Selected items will be deleted."
        let alertController = UIAlertController(title: titleText, message: nil, preferredStyle: .ActionSheet)
        
        let itemWithPlural = selectedMemes.count == 1 ? "item" : "items"
        let resetAction = UIAlertAction(title:"Delete \(selectedMemes.count) \(itemWithPlural)", style: .Destructive) { action in
            for meme in self.selectedMemes {
                let index = self.memes.indexOf(meme)!
                (UIApplication.sharedApplication().delegate as! AppDelegate).memes.removeAtIndex(index)
            }
            self.toggleSelectButton()
            self.memeCollectionView.reloadData()
        }
        let cancelAction = UIAlertAction(title:"Cancel", style: .Cancel, handler: nil)
        
        alertController.addAction(resetAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Helper Functions
    func setCollectionViewWithSelectingStatus(isSelecting: Bool) {
        self.isSelecting = !isSelecting
        selectButton.title = ""
        selectButton.title = isSelecting ? "Select" : "Cancel"
        isSelecting ? deSelectMemes() : ()
        memeCollectionView.allowsMultipleSelection = !isSelecting
        setUIView(tabBarController!.tabBar, withAlpha: CGFloat(isSelecting ? 1 : 0))
        let rightBarButton = isSelecting ? UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addMeme)) : UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action:#selector(deleteSelectedItems))
        navigationItem.rightBarButtonItem = rightBarButton
        isSelecting ? (selectButton.enabled = !memes.isEmpty) : autoEnableTrashButton()
        
    }
    
    func deSelectMemes() {
        if let indexPaths = memeCollectionView.indexPathsForSelectedItems() {
            for indexPath in indexPaths {
                setCheckmarkImage(nil, forCellAtIndexPath: indexPath)
                memeCollectionView.deselectItemAtIndexPath(indexPath, animated: false)
            }
            selectedMemes.removeAll()
        }
    }

    func autoEnableTrashButton() {
        navigationItem.rightBarButtonItem?.enabled = !selectedMemes.isEmpty
    }
    
    func setCheckmarkImage(image: UIImage?, forCellAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = memeCollectionView.cellForItemAtIndexPath(indexPath) as! MemeCollectionViewCell
        selectedCell.checkMark.image = image
    }
}


// MARK:- CollectionView Delegate FlowLayout
extension MemeCollectionViewController: UICollectionViewDelegateFlowLayout {
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
}


// MARK:- CollectionView Delegate
extension MemeCollectionViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if !isSelecting {
            performSegueWithIdentifier(segueFromCollectionToEditorID, sender: self)
        } else {
            let image = UIImage(named: "checkmark")
            setCheckmarkImage(image, forCellAtIndexPath: indexPath)
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
}


// MARK:- CollectionView Data Source
extension MemeCollectionViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let meme = memes[indexPath.row]
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("memeCollectionCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        cell.memedImage.image = meme.memedImage
        return cell
    }
}
