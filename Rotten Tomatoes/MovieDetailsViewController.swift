//
//  MovieDetailsViewController.swift
//  Rotten Tomatoes
//
//  Created by Adam Crabtree on 2/8/15.
//  Copyright (c) 2015 Adam Crabtree. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var textView: UITextView!
    var data: JSON!
    var thumbnail: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let title = data["title"].string {
            self.title = title
        }
        
        self.posterImage.image = self.thumbnail
        if let url = self.data["posters"]["thumbnail"].string {
            let hdUrl = url.stringByReplacingOccurrencesOfString("tmb", withString: "ori")
            
            self.posterImage.setImageWithURL(NSURL(string: hdUrl))
        }
        
        
        textView.backgroundColor = UIColor.whiteColor()
        textView.text = data["synopsis"].string
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
