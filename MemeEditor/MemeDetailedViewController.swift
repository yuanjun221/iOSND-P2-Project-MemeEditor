//
//  MemeDetailedViewController.swift
//  MemeEditor
//
//  Created by Jun.Yuan on 16/6/10.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import UIKit

class MemeDetailedViewController: UIViewController {
    
    var meme: Meme!
    
    @IBOutlet weak var memedImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        memedImageView.image = meme.memedImage
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let bar = navigationController!.navigationBar
        setBarAndImageView(bar, imageView: memedImageView)
    }
    
    func setBarAndImageView(UIBar: UIView, imageView: UIImageView) {
        if UIBar.alpha == 0.0 {
            setUIView(UIBar, withAlpha: 1.0)
            setUIView(imageView, withBackgroundColor: UIColor.whiteColor())
        } else {
            setUIView(UIBar, withAlpha: 0.0)
            setUIView(imageView, withBackgroundColor: UIColor.blackColor())
        }
    }
    

}
