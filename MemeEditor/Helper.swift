//
//  Helper.swift
//  MemeEditor
//
//  Created by Jun.Yuan on 16/6/11.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import Foundation
import UIKit

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
