//
//  FilterService.swift
//  Photo Filter
//
//  Created by Sam Wilskey on 8/11/15.
//  Copyright (c) 2015 Wilskey Labs. All rights reserved.
//

import UIKit

class FilterService {
  
  class func sepiaImageFromOriginalImage(original: UIImage, context: CIContext) -> UIImage {
    
    let image = CIImage(image: original)
    let filter = CIFilter(name: "CISepiaTone")
    let name = filter.name()
    filter.setValue(image, forKey: kCIInputImageKey)
    
    return getFinalImage(filter, context: context)
  }
  
  class func pixellateImageFromOriginalImage(original: UIImage, context: CIContext) -> UIImage {
    
    let image = CIImage(image: original)
    let filter = CIFilter(name: "CIPixellate")
    let name = filter.name()
    filter.setValue(image, forKey: kCIInputImageKey)
    
    return getFinalImage(filter, context: context)
  }
  
  class func monoImageFromOriginalImage(original: UIImage, context: CIContext) -> UIImage {
    
    let image = CIImage(image: original)
    let filter = CIFilter(name: "CIPhotoEffectMono")
    let name = filter.name()
    filter.setValue(image, forKey: kCIInputImageKey)
    
    return getFinalImage(filter, context: context)
  }
  
  class func invertImageFromOriginalImage(original: UIImage, context: CIContext) -> UIImage {
    
    let image = CIImage(image: original)
    let filter = CIFilter(name: "CIColorInvert")
    let name = filter.name()
    filter.setValue(image, forKey: kCIInputImageKey)
    
    return getFinalImage(filter, context: context)
  }
  
  class func photoEffectFromOriginalImage(original: UIImage, context: CIContext) -> UIImage {
    let image = CIImage(image: original)
    let filter = CIFilter(name: "CIPhotoEffectProcess")
    let name = filter.name()
    filter.setValue(image, forKey: kCIInputImageKey)
    
    return getFinalImage(filter, context: context)
  }
  
  private class func getFinalImage(filter: CIFilter, context: CIContext) -> UIImage {
    let outputImage = filter.outputImage
    let extent = outputImage.extent()
    let cgImage = context.createCGImage(outputImage, fromRect: extent)
    let finalImage = UIImage(CGImage: cgImage)
    return finalImage!
  }
}
