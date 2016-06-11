//
//  Helper.swift
//  MemeEditor
//
//  Created by Jun.Yuan on 16/6/11.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import Foundation
import UIKit

func hideOrShowBar(bar: UIView) {
    if bar.alpha == 0.0 {
        setBar(bar, withAlpha: 1.0)
    } else {
        setBar(bar, withAlpha: 0.0)
    }
}

func setBar(bar:UIView, withAlpha alpha:CGFloat) {
    UIView.animateWithDuration(0.3, animations: {bar.alpha = alpha})
}
