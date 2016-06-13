//
//  MemeStruct.swift
//  UIImagePickerExperiment
//
//  Created by Jun.Yuan on 16/6/6.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import Foundation
import UIKit

struct Meme:Equatable {
    var topText: String
    var bottomText: String
    var originImage: UIImage
    var memedImage: UIImage
}

struct MemeEditorStatus: Equatable {
    var topText: String!
    var bottomText: String!
    var originImage: UIImage?
}