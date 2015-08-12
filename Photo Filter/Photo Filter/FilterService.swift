//
//  FilterService.swift
//  Photo Filter
//
//  Created by Sam Wilskey on 8/11/15.
//  Copyright (c) 2015 Wilskey Labs. All rights reserved.
//

import UIKit

class FilterService {

  
  class func filter(filterName: String, image: UIImage) -> UIImage? {
    
    let image = CIImage(image: image)
    let filter = CIFilter(name: filterName)
    filter.setValue(image, forKey: kCIInputImageKey)
    
    let options = [kCIContextWorkingColorSpace : NSNull()]
    let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
    let gpuContext = CIContext(EAGLContext: eaglContext, options: options)
    
    let outputImage = filter.outputImage
    let extent = outputImage.extent()
    let cgImage = gpuContext.createCGImage(outputImage, fromRect: extent)
    let finalImage = UIImage(CGImage: cgImage)
    return finalImage
  }
}
