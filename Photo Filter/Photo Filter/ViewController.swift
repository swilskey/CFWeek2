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
  
  //TODO: Add a default image so that it is not blank
  
  let kContainerViewBottomPhonePadding: CGFloat = -150
  let kThumbnailImageSize: CGSize = CGSize(width: 200, height: 200)
  let kDefaultAnimationLength: NSTimeInterval = 0.3
  
  //MARK: Outlets
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var optionButton: UIButton!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var collectionVerticalSpace: NSLayoutConstraint!
  
  var imageCache = [String: UIImage]()
  var thumbnail: UIImage?
  var commentTextField: UITextField?
  var displayImage: UIImage? {
    didSet {
      imageCache.removeAll(keepCapacity: false)
      imageView.image = displayImage
      thumbnail = ImageResizer.resizeImage(displayImage!, size: kThumbnailImageSize)
      collectionView.reloadData()
    }
  }
  
  let gpuContext = CIContext(EAGLContext: EAGLContext(API: EAGLRenderingAPI.OpenGLES2), options: [kCIContextWorkingColorSpace : NSNull()])
  let filterQueue = NSOperationQueue()
  let filters: [(UIImage, CIContext)-> (UIImage)] = [FilterService.sepiaImageFromOriginalImage, FilterService.pixellateImageFromOriginalImage,
    FilterService.monoImageFromOriginalImage, FilterService.invertImageFromOriginalImage, FilterService.photoEffectFromOriginalImage]
  
  let actionController = UIAlertController(title: "Filter Options", message: "Select a Image or a Filter", preferredStyle: UIAlertControllerStyle.ActionSheet)
  let commentAlert = UIAlertController(title: "Comment", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
  let picker = UIImagePickerController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    picker.delegate = self
    collectionView.dataSource = self
    collectionView.delegate = self
    displayImage = UIImage(named: "seattle.png")
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert) -> Void in
      
    }
    
    let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .Default) { (alert) -> Void in
      self.picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
      self.presentViewController(self.picker, animated: true, completion: nil)
    }
    
    let photoAction = UIAlertAction(title: "Camera", style: .Default) { (alert) -> Void in
      self.picker.sourceType = UIImagePickerControllerSourceType.Camera
      self.presentViewController(self.picker, animated: true, completion: nil)
    }
    
    let commentAction = UIAlertAction(title: "Ok", style: .Default) { (alert) in
      self.commentTextField = self.commentAlert.textFields![0] as? UITextField
      let post = PFObject(className: "Post")
      
      if let image = self.imageView.image,
        data = UIImageJPEGRepresentation(image, 1.0) {
          let file = PFFile(name: "image.jpeg" ,data: data)
          post["image"] = file
          post["comment"] = self.commentTextField?.text
      }
      post.saveInBackgroundWithBlock({ (success, error) -> Void in
        
      })
    }
    commentAction.enabled = false
    
    commentAlert.addTextFieldWithConfigurationHandler { (textField) in
      textField.placeholder = "Comment"
      
      NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
        commentAction.enabled = textField.text != ""
      }
    }
    
    let uploadAction = UIAlertAction(title: "Upload", style: .Default) { (alert) -> Void in
      self.presentViewController(self.commentAlert, animated: true, completion: nil)
    }
    
    let galleryAction = UIAlertAction(title: "Gallery", style: .Default) { (alert) -> Void in
      self.performSegueWithIdentifier("ShowGallery", sender: self)
    }
    
    if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
      let filterAction = UIAlertAction(title: "Filter Mode", style: .Default) { (alert) -> Void in
        self.filterMode()
        
      }
      actionController.addAction(filterAction)
    }
    
    
    actionController.addAction(photoLibraryAction)
    actionController.addAction(photoAction)
    actionController.addAction(uploadAction)
    actionController.addAction(galleryAction)
    actionController.addAction(cancelAction)
    
    commentAlert.addAction(commentAction)
    commentAlert.addAction(cancelAction)
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
  
  
  //MARK: Helper Methods
  func filterMode() {
    UIView.animateWithDuration(kDefaultAnimationLength, animations: { () -> Void in
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
    UIView.animateWithDuration(kDefaultAnimationLength, animations: { () -> Void in
      self.collectionVerticalSpace.constant = self.kContainerViewBottomPhonePadding
      self.navigationController?.navigationBarHidden = true
      self.optionButton.hidden = false
      self.view.layoutIfNeeded()
    })
  }
  
  func cancelMethod() {
    UIView.animateWithDuration(kDefaultAnimationLength, animations: { () -> Void in
      self.imageView.image = self.displayImage
      self.collectionVerticalSpace.constant = self.kContainerViewBottomPhonePadding
      self.navigationController?.navigationBarHidden = true
      self.optionButton.hidden = false
      self.view.layoutIfNeeded()
      
    })
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowGallery" {
      if let galleryViewController = segue.destinationViewController as? GalleryViewController {
        galleryViewController.delegate = self
        galleryViewController.desiredFinalImageSize = imageView.frame.size
      }
    }
  }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    let image = info[UIImagePickerControllerOriginalImage] as? UIImage
    self.displayImage = image!
    self.picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    self.picker.dismissViewControllerAnimated(true, completion: nil)
  }
}

//MARK: CollectionView
extension ViewController: UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FilterCell", forIndexPath: indexPath) as! ImageCell
    cell.tag++
    let tag = cell.tag
    
    cell.thumbnailView.image = nil
    
    if imageCache[String(indexPath.item)] != nil {
      cell.thumbnailView.image = imageCache[String(indexPath.item)]
      println("using cache")
      return cell
    }
    
    filterQueue.addOperationWithBlock { () -> Void in
      
      if let image = self.thumbnail {
        let filter = self.filters[indexPath.item]
        let filteredImage = filter(image, self.gpuContext)
        self.imageCache[String(indexPath.item)] = filteredImage
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
          cell.thumbnailView.image = filteredImage
        })
      }
    }
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return filters.count
  }
}

extension ViewController: UICollectionViewDelegate {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if let image = self.displayImage {
      let filter = filters[indexPath.item]
      filterQueue.addOperationWithBlock({ () -> Void in
        let finalImage = filter(image, self.gpuContext)
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
          self.imageView.image = finalImage
        })
      })
    }
  }
}

extension ViewController : ImageSelectedDelegate {
  func controllerDidSelectImage(newImage: UIImage) {
    println(newImage.size)
    displayImage = newImage
  }
}