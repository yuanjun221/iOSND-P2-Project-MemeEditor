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

    @IBOutlet var memeCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addMeme))
        memeCollectionView.allowsMultipleSelection = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        memeCollectionView.reloadData()
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
        let detailedVC = segue.destinationViewController as! MemeDetailedViewController
        detailedVC.hidesBottomBarWhenPushed = true
        let indexPathArray = memeCollectionView.indexPathsForSelectedItems()!
        detailedVC.meme = memes[indexPathArray[0].row]
        detailedVC.indexPath = indexPathArray[0]
    }
}
