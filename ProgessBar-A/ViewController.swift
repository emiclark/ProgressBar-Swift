//
//  ViewController.swift
//  ProgessBar-A
//
//  - Create and set gradient background colors
//  - Download an image in the background while updating progress Bar
//  - Display downloaded image when it's complete
//
//  Created by Emiko Clark on 5/25/16.
//  Copyright © 2016 Emiko Clark. All rights reserved.
//

import UIKit


class ViewController: UIViewController , NSURLSessionDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var percentDownloaded: UILabel! //outlet for label showing percent downloaded
    
    @IBOutlet weak var progressBar: UIProgressView! //outlet for progressBar
    
    @IBOutlet weak var downloadButton: UIButton! //outlet for download button
    
    var downloadTask: NSURLSessionDownloadTask! //declare downloadTask variabe of type NSURLSessionDownloadTask
    
    var backgroundSession: NSURLSession! //declare backgroundSession variable of type NSURLSession
    
    
    // MARK: - View Controller methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // set up gradient pattern for background
        addGradientBackground()
        
        //create NSURLSessionConfiguration to a background session
        let backgroundSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("backgroundSession")
        
        // set backgroundSession configuration, delegate, and main queue
        backgroundSession = NSURLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        
        //set progressBar to 0%
        self.progressBar.setProgress(0.0, animated: false)
        
    }
    
    //enforces portrait mode
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    //enforces portrait mode
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    // MARK: - Download / Network call methods
    
    @IBAction func downloadButtonTapped(sender: UIButton) {
        //reset background to gradient if download button is hit more than once
        self.imageView.image = nil
        self.progressBar.setProgress(0.0, animated: false) //set progressBar to 0%
        
        //set url of image to download
        let url = NSURL(string:"http://mmd.ninjacdn.com/images/brandphotos/HighRes/Image7HighRes_9.jpg")
        
        //set downloadTask to backgroundSession with url of image
        downloadTask = backgroundSession.downloadTaskWithURL(url!)
        
        //start the download task
        downloadTask.resume()
        
        print("Download Started")
    }
    
    
    
    // this is a delegate method that handles how tracks total size downloaded and total file size
    func URLSession(session: NSURLSession,
                    downloadTask: NSURLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                                 totalBytesWritten: Int64,
                                 totalBytesExpectedToWrite: Int64){
        
        //update progress bar and progressbar label with percent of data downloaded
        progressBar.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
        
        //calculate percentage downloaded
        let percentDownloadedValue  = (Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)) * 100
        
        //update the label to show percentage downloaded
        percentDownloaded.text = "\(Int(percentDownloadedValue)) %"
        
    }
    
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL){
        
        //set path to documents directory
        let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        
        //get path name in index 0
        let documentDirectoryPath:String = path[0]
        
        //create filemanager object
        let fileManager = NSFileManager()
        
        //set destination path and file type(.jpg) for file to download
        let destinationURLForFile = NSURL(fileURLWithPath: documentDirectoryPath.stringByAppendingString("/file.jpg"))
        
        //check if file downloaded and saved successfully to destination path
        if fileManager.fileExistsAtPath(destinationURLForFile.path!){
            
            //display downloaded image to imageView
            displayImageWithPath(destinationURLForFile.path!)
        }
        
        else{
            // file downloaded as a .tmp file, move to documents dir after download is complete
            do {
                // try to move .tmp to documents directory
                try fileManager.moveItemAtURL(location, toURL: destinationURLForFile)

                //if successful, display downloaded image to imageView
                displayImageWithPath(destinationURLForFile.path!)

            }catch{
                print("An error occurred while moving file to destination url")
            }
        }
    }
    
    
    // MARK: - Utility methods
    
    func addGradientBackground() {
        
        //display gradient background for view
        let gradientLayer = CAGradientLayer()
        
        //set gradientLayer to the size of the view.frame (full screen)
        gradientLayer.frame = self.view.frame
        
        //set gradient colors for top and bottom
        let topColor = UIColor(red: 73.0/255.0, green: 223.0/255.0, blue: 185.0/255.0, alpha: 1.0)
        let bottomColor = UIColor(red: 36.0/255.0, green: 115/255.0, blue: 192.0/255, alpha: 1.0)
        
        //add colors to array to gradiate between
        let gradientColorsArray = [topColor.CGColor, bottomColor.CGColor]
        gradientLayer.colors = gradientColorsArray
        
        //set the location of where colors should gradiate between
        gradientLayer.locations = [0.0, 1.0]
        
        /* Every UIView has a layer - into that layer you can add sublayers,
            just as you can add subviews. One specific type is the CAGradientLayer, 
            where you give it an array of colors to gradiate between.
            - insert the colors layer into view
        */
        self.view.layer.insertSublayer(gradientLayer, atIndex: 0)

    }
    
    
    func displayImageWithPath(path: String){
        
        //checks if file is at file path
        let isFileFound:Bool? = NSFileManager.defaultManager().fileExistsAtPath(path)
        
        //if file exists, display to uiimageview
        if isFileFound == true{
            print(path)
            //display image in imageView
            self.imageView?.image = UIImage(contentsOfFile: path)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

