//
//  MemeStruct.swift
//  UIImagePickerExperiment
//
//  Created by Jun.Yuan on 16/6/6.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import Foundation
import UIKit

struct Meme {
    var topText: String
    var bottomText: String
    var originImage: UIImage
    var memedImage: UIImage
}

struct MemeEditorStatus {
    var topText: String!
    var bottomText: String!
    var originImage: UIImage?
}