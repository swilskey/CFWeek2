//
//  ViewController.swift
//  Photo Filter
//
//  Created by Sam Wilskey on 8/10/15.
//  Copyright (c) 2015 Wilskey Labs. All rights reserved.
//

import UIKit
import Bolts
import Parse

class ViewController: UIViewController {
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var optionButton: UIButton!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var collectionVerticalSpace: NSLayoutConstraint!
  
  let filters = ["CISepiaTone", "CIPixellate", "CIColorInvert"]
  var thumbnail: UIImage?
  
  var currentImage: UIImage? {
    didSet {
      imageView.image = currentImage
      thumbnail = ImageResizer.resizeImage(currentImage!, size: CGSize(width: 100, height: 100))
      filterMode()
      collectionView.reloadData()
    }
  }
  
  let actionController = UIAlertController(title: "Filter Options", message: "Select a Image or a Filter", preferredStyle: UIAlertControllerStyle.ActionSheet)
  
  let picker = UIImagePickerController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    picker.delegate = self
    collectionView.dataSource = self
    collectionView.delegate = self
    
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
    
    if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
      let filterAction = UIAlertAction(title: "Filter Mode", style: .Default) { (alert) -> Void in
        self.filterMode()
        
      }
      actionController.addAction(filterAction)
    }
    
    let uploadAction = UIAlertAction(title: "Upload", style: .Default) { (alert) -> Void in
      let post = PFObject(className: "Post")
      
      if let image = self.imageView.image,
      data = UIImageJPEGRepresentation(image, 1.0) {
        let file = PFFile(name: "image.jpeg" ,data: data)
        post["image"] = file
      }
      post.saveInBackgroundWithBlock({ (success, error) -> Void in
        
      })
    }

    actionController.addAction(galleryAction)
    actionController.addAction(photoAction)
    actionController.addAction(uploadAction)
    actionController.addAction(cancelAction)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  
  @IBAction func actionButton(sender: UIButton) {
    if let popover = actionController.popoverPresentationController {
      popover.sourceRect = optionButton.frame
      popover.sourceView = view
    }
    self.presentViewController(actionController, animated: true, completion: nil)
  }
  
  func filterMode() {
    UIView.animateWithDuration(0.3, animations: { () -> Void in
      
      self.collectionVerticalSpace.constant = 8
      let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "doneMethod")
      let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancelMethod")
      self.navigationItem.leftBarButtonItem = doneButton
      self.navigationItem.rightBarButtonItem = cancelButton
      self.navigationController?.navigationBarHidden = false
      self.optionButton.hidden = true
      self.view.layoutIfNeeded()
    })
  }
  
  func doneMethod() {
    UIView.animateWithDuration(0.3, animations: { () -> Void in
      self.collectionVerticalSpace.constant = -150
      self.navigationController?.navigationBarHidden = true
      self.optionButton.hidden = false
      self.view.layoutIfNeeded()
    })
  }
  
  func cancelMethod() {
    UIView.animateWithDuration(0.3, animations: { () -> Void in
      self.imageView.image = self.currentImage
      self.collectionVerticalSpace.constant = -150
      self.navigationController?.navigationBarHidden = true
      self.optionButton.hidden = false
      self.view.layoutIfNeeded()
      
    })
  }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    let image = info[UIImagePickerControllerOriginalImage] as? UIImage
    self.currentImage = image!
    self.picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    self.picker.dismissViewControllerAnimated(true, completion: nil)
  }
}

extension ViewController: UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCell
    if let image = thumbnail {
      cell.thumbnailView.image = FilterService.filter(filters[indexPath.item], image: image)
    }
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return filters.count
  }
}

extension ViewController: UICollectionViewDelegate {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if let image = self.currentImage {
      let finalImage = FilterService.filter(filters[indexPath.item], image: image)
      self.imageView.image = finalImage
    }
  }
}