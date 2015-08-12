//
//  ImageResizer.swift
//  Photo Filter
//
//  Created by Sam Wilskey on 8/12/15.
//  Copyright (c) 2015 Wilskey Labs. All rights reserved.
//

import UIKit

class ImageResizer {
  
  class func resizeImage(image: UIImage, size: CGSize) -> UIImage {
    UIGraphicsBeginImageContext(size)
    image.drawInRect(CGRect(origin: CGPoint(x: 0, y: 0), size: size))
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return resizedImage
  }
}