//
//  GalleryViewController.swift
//  Photo Filter
//
//  Created by Sam Wilskey on 8/13/15.
//  Copyright (c) 2015 Wilskey Labs. All rights reserved.
//

import UIKit
import Photos

protocol ImageSelectedDelegate: class {
  func controllerDidSelectImage(UIImage) -> (Void)
}

class GalleryViewController: UIViewController {
  
  @IBOutlet weak var galleryCollectionView: UICollectionView!
  
  let backgroundQueue = NSOperationQueue()
  let cellThumbnailSize = CGSize(width:100, height: 100)
  
  weak var delegate: ImageSelectedDelegate?
  var fetchResult: PHFetchResult!
  var desiredFinalImageSize : CGSize!
  var startingScale: CGFloat = 0
  var scale: CGFloat = 0
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    galleryCollectionView.dataSource = self
    galleryCollectionView.delegate = self
    navigationController?.navigationBarHidden = false
    fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
    
    var pinchAction = UIPinchGestureRecognizer(target: self, action: "pinchRecognized:")
    galleryCollectionView.addGestureRecognizer(pinchAction)
  }
  
  func pinchRecognized(pinch: UIPinchGestureRecognizer) {
    if pinch.state == UIGestureRecognizerState.Began {
      startingScale = pinch.scale
    }
    
    if pinch.state == UIGestureRecognizerState.Ended {
      scale = startingScale * pinch.scale
      let layout = galleryCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
      let newSize = CGSize(width: layout.itemSize.width * scale, height: layout.itemSize.height * scale)
      
      galleryCollectionView.performBatchUpdates({ () -> Void in
        layout.itemSize = newSize
        layout.invalidateLayout()
        }, completion: nil )
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}

extension GalleryViewController: UICollectionViewDataSource {
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCell
    if let asset = fetchResult[indexPath.row] as? PHAsset {
      PHCachingImageManager.defaultManager().requestImageForAsset(asset, targetSize: cellThumbnailSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
        cell.thumbnailView.image = image
      }
    }
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return fetchResult.count
  }
}

extension GalleryViewController: UICollectionViewDelegate {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let options = PHImageRequestOptions()
    options.synchronous = true

    backgroundQueue.addOperationWithBlock { () -> Void in
      if let asset = self.fetchResult[indexPath.row] as? PHAsset {
        PHCachingImageManager.defaultManager().requestImageForAsset(asset, targetSize: self.desiredFinalImageSize, contentMode: PHImageContentMode.AspectFill, options: options) { (image, info) -> Void in
          
          if let image = image {
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
              self.delegate?.controllerDidSelectImage(image)              
              self.navigationController?.popViewControllerAnimated(true)
            })
          }
        }
      }
    }
  }
}