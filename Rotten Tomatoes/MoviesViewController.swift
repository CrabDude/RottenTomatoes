//
//  MoviesViewController.swift
//  Rotten Tomatoes
//
//  Created by Adam Crabtree on 2/2/15.
//  Copyright (c) 2015 Adam Crabtree. All rights reserved.
//

import UIKit
import MRProgress

let RTApiKey = "ndzr84kwnfkkpf2nbdcuabbm"
let RTListUrlPrefix = "http://api.rottentomatoes.com/api/public/v1.0/lists"
let RTDvdUrl = "\(RTListUrlPrefix)/dvds/top_rentals.json?apikey=\(RTApiKey)"
let RTBoxOfficeUrl = "\(RTListUrlPrefix)/movies/box_office.json?apikey=\(RTApiKey)"
let dvdUrl = NSURL(string: RTDvdUrl)!
let boxOfficeUrl = NSURL(string: RTBoxOfficeUrl)!

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tabBar: UITabBar!
    lazy var refreshControl = UIRefreshControl()
    var data: JSON?
    var errorLabel: UILabel!
    var url = dvdUrl
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Rotten Tomatoes"

        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex:0)
        
        tableView.registerNib(UINib(nibName: "MovieCell", bundle: nil), forCellReuseIdentifier: "MovieCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 200
        
        tabBar.delegate = self
        tabBar.selectedItem = tabBar.items?[0] as? UITabBarItem

        errorLabel = UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 20))
        errorLabel.hidden = true
        errorLabel.backgroundColor = UIColor.blueColor()
        errorLabel.textAlignment = NSTextAlignment.Center
        errorLabel.textColor = UIColor.whiteColor()
        errorLabel.numberOfLines = 1
        errorLabel.font = UIFont.systemFontOfSize(13)
        errorLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
        errorLabel.text = "Error..."
        tableView.addSubview(errorLabel)

        MRProgressOverlayView.showOverlayAddedTo(tableView, animated: true)
        loadData { _ = MRProgressOverlayView.dismissOverlayForView(self.tableView, animated: true) }
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell") as MovieCell
        
//        println("Loading cell: %@", indexPath.row)
        if let data = self.data?["movies"][indexPath.row] {
            if let title = data["title"].string {
                cell.titleLabel.text = title
            }
            
            if let synopsis = data["synopsis"].string {
                cell.descriptionLabel.text = synopsis
            }
            
            if let urlString = data["posters"]["thumbnail"].string {
                if let url = NSURL(string: urlString) {
                    if let imageView = cell.movieImage {
                        let request = NSURLRequest(URL: url)
                        
                        imageView.setImageWithURLRequest(request, placeholderImage: nil, success: {
                            (request, response, image) -> Void in
//                            println("Setting image: %@", url)
                            
                            UIView.transitionWithView(imageView, duration: 1.0, options:UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                                imageView.image = image
                                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                                }, completion: nil)
                            }, failure: {
                                (request, response, error) -> Void in
                                self.fadeLabelIn(error.localizedDescription)
                        })
                    }
                }
            }
        }
        return cell

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = self.data?["movies"].array {
//            println(data.count)
            return data.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let vc = MovieDetailsViewController(nibName: "MovieDetailsViewController", bundle: nil)
        vc.data = self.data?["movies"][indexPath.row]
        if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? MovieCell {
            vc.thumbnail = cell.movieImage?.image
        }
                
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onRefresh() {
//        println("onRefresh")
        loadData { self.refreshControl.endRefreshing(); self.fadeLabelOut() }
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        url = dvdUrl
        if let firstItem = tabBar.items?[0] as? UITabBarItem {
            if tabBar.selectedItem != firstItem {
                url = boxOfficeUrl
            }
        }
        
        MRProgressOverlayView.showOverlayAddedTo(tableView, animated: true)
        loadData { _ = MRProgressOverlayView.dismissOverlayForView(self.tableView, animated: true) }
    }

    private func loadData(completionHandler: (() -> Void)? = nil) {
        let request = NSURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler:{
            (response, data, error) in
            if let error = error {
                self.fadeLabelIn(error.localizedDescription)
            } else {
                self.data = JSON(data: data)
                //            println(self.data)
                
//                println("Reloading data...")
                self.tableView.reloadData()
            }
            
            completionHandler?()
        })
    }
    
    private func fadeLabelIn(message: String) {
        errorLabel.alpha = 0
        errorLabel.hidden = false
        errorLabel.text = message
        UIView.animateWithDuration(0.5) {
            self.errorLabel.alpha = 1
            let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(10) * Double(NSEC_PER_SEC)))
            dispatch_after(delay, dispatch_get_main_queue()) {
                self.fadeLabelOut()
            }
        }
    }
    
    
    private func fadeLabelOut() {
        UIView.animateWithDuration(0.5, animations: {
            self.errorLabel.alpha = 0
        }, completion: { finished in
            self.errorLabel.hidden = finished
        })
    }
}
