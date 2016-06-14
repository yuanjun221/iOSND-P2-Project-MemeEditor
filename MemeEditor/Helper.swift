//
//  Helper.swift
//  MemeEditor
//
//  Created by Jun.Yuan on 16/6/11.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import Foundation
import UIKit

let memeEditorViewControllerID = "MemeEditorViewController"
let segueFromCollectionToEditorID = "collectionToEditor"

func hideOrShowBar(UIBar: UIView) {
    if UIBar.alpha == 0.0 {
        setUIView(UIBar, withAlpha: 1.0)
    } else {
        setUIView(UIBar, withAlpha: 0.0)
    }
}

func setUIView(view:UIView, withAlpha alpha:CGFloat) {
    UIView.animateWithDuration(0.3, animations: {view.alpha = alpha})
}

func setUIView(view:UIView, withBackgroundColor color: UIColor) {
    UIView.animateWithDuration(0.3, animations: {view.backgroundColor = color})
}

func enableButton(button: UIBarButtonItem, withMemesCount count: Int) {
    if count == 0 {
        button.enabled = false
    } else {
        button.enabled = true
    }
}

func setSegue(segue: UIStoryboardSegue, withMemes memes:[Meme], indexPath: NSIndexPath) {
    let detailedVC = segue.destinationViewController as! MemeDetailedViewController
    detailedVC.hidesBottomBarWhenPushed = true
    detailedVC.meme = memes[indexPath.row]
    detailedVC.indexPath = indexPath
    detailedVC.memeArrayCount = memes.count
}

func == (left:Meme, right:Meme) -> Bool {
    return (left.topText == right.topText) && (left.bottomText == right.bottomText) && (left.originImage == right.originImage) && (left.memedImage == right.memedImage)
}

func == (left: MemeEditorStatus, right: MemeEditorStatus) -> Bool {
    return (left.topText == right.topText) && (left.bottomText == right.bottomText) && (left.originImage == right.originImage)
}