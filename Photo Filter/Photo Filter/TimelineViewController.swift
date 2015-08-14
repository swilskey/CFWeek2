//
//  TimelineViewController.swift
//  Photo Filter
//
//  Created by Sam Wilskey on 8/11/15.
//  Copyright (c) 2015 Wilskey Labs. All rights reserved.
//

import UIKit
import Bolts
import Parse

class TimelineViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  
  var posts:[PFObject] = [PFObject]()
  var imageCache = [String: UIImage]()
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    let query = PFQuery(className: "Post")
    
    query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
      if let error = error {
        println(error.localizedDescription)
      } else if let posts = results as? [PFObject] {
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
          self.posts = posts
          self.tableView.reloadData()
        })
      }
    }

  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dataSource = self
    tableView.registerNib(UINib(nibName: "TimelineCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TimelineCell")
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}

extension TimelineViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier("TimelineCell", forIndexPath: indexPath) as! TimelineCell
    cell.parseImagePreview.image = nil
    
    cell.tag++
    let tag = cell.tag

    if let post = posts[indexPath.item] as PFObject!,
      imageFile = post["image"] as? PFFile,
      objectID = post.objectId {
        if let comment = post["comment"] as? String {
          cell.messageLabel.text = comment
        } else {
          cell.messageLabel.text = "No Comment"
        }
        if imageCache[objectID] != nil {
          if cell.tag == tag {
            cell.parseImagePreview.image = imageCache[objectID]
          }
        } else {
          imageFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
            if let error = error {
              println(error.localizedDescription)
            } else if let data = data,
              image = UIImage(data: data) {
                let finalImage = ImageResizer.resizeImage(image, size: CGSize(width: 200, height: 200))
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                  if cell.tag == tag {
                    self.imageCache[objectID] = finalImage
                    cell.parseImagePreview.image = finalImage
                  }
                })
            }
          })
        }
    }
    
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return posts.count
  }
}

extension TimelineViewController: UITableViewDelegate {
  
}
