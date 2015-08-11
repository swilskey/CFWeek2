//
//  ViewController.swift
//  Photo Filter
//
//  Created by Sam Wilskey on 8/10/15.
//  Copyright (c) 2015 Wilskey Labs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  @IBOutlet weak var imageView: UIImageView!
  
  let actionController = UIAlertController(title: "Filter Options", message: "Select a Image or a Filter", preferredStyle: UIAlertControllerStyle.ActionSheet)
  let picker = UIImagePickerController()

  override func viewDidLoad() {
    super.viewDidLoad()
    picker.delegate = self
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert) -> Void in
      
    }
    
    let galleryAction = UIAlertAction(title: "Gallery", style: .Default) { (alert) -> Void in
      self.picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
      self.presentViewController(self.picker, animated: true, completion: nil)
    }
    
    let photoAction = UIAlertAction(title: "Camera", style: .Default) { (alert) -> Void in
      self.picker.sourceType = UIImagePickerControllerSourceType.Camera
      self.presentViewController(self.picker, animated: true, completion: nil)
    }
    
    let sepiaAction = UIAlertAction(title: "Sepia Filter", style: .Default) { (alert) -> Void in
      let image = CIImage(image: self.imageView.image)
      let filter = CIFilter(name: "CISepiaTone")
      filter.setValue(image, forKey: kCIInputImageKey)
      
      let options = [kCIContextWorkingColorSpace : NSNull()]
      let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
      let gpuContext = CIContext(EAGLContext: eaglContext, options: options)
      
      let outputImage = filter.outputImage
      let extent = outputImage.extent()
      let cgImage = gpuContext.createCGImage(outputImage, fromRect: extent)
      let finalImage = UIImage(CGImage: cgImage)
      self.imageView.image = finalImage
    }
    
    actionController.addAction(galleryAction)
    actionController.addAction(photoAction)
    actionController.addAction(sepiaAction)
    actionController.addAction(cancelAction)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


  @IBAction func actionButton(sender: UIButton) {
    self.presentViewController(actionController, animated: true, completion: nil)
  }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    let image = info[UIImagePickerControllerOriginalImage] as? UIImage
    self.imageView.image = image
    self.picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    self.picker.dismissViewControllerAnimated(true, completion: nil)
  }
}