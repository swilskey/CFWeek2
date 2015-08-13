//
//  GalleryViewController.swift
//  Photo Filter
//
//  Created by Sam Wilskey on 8/13/15.
//  Copyright (c) 2015 Wilskey Labs. All rights reserved.
//

import UIKit
import Bolts
import Parse

class GalleryViewController: UIViewController {
  @IBOutlet weak var galleryCollectionView: UICollectionView!
  
  
  var posts = [PFObject]()
  var imageCache = [String: UIImage]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBarHidden = false
    galleryCollectionView.dataSource = self
    
    let query = PFQuery(className: "Post")
    
    query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
      if let error = error {
        println(error.localizedDescription)
      } else if let posts = results as? [PFObject] {
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
          self.posts = posts
          println(posts.count)
          self.galleryCollectionView.reloadData()
        })
      }
    }
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}

extension GalleryViewController: UICollectionViewDataSource {
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! GalleryCell
    
    cell.tag++
    
    let tag = cell.tag
    
    if let post = posts[indexPath.item] as PFObject!,
      imageFile = post["image"] as? PFFile,
      objectID = post.objectId {
        if imageCache[objectID] != nil {
          println("From Cache")
          if cell.tag == tag {
            cell.galleryImage.image = imageCache[objectID]
          }
        } else {
          imageFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
            if let error = error {
              println(error.localizedDescription)
            } else if let data = data,
              image = UIImage(data: data) {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                  let finalImage = ImageResizer.resizeImage(image, size: CGSize(width: 400, height: 400))
                  if cell.tag == tag {
                    self.imageCache[objectID] = image
                    cell.galleryImage.image = image
                  }
                })
            }
          })
        }
    }

    return cell
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return posts.count
  }
}
