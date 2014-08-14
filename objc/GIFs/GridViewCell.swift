//
//  GridViewCell.swift
//  GIFs
//
//  Created by Orta on 8/5/14.
//  Copyright (c) 2014 Orta Therox. All rights reserved.
//

import Cocoa

@objc class GridViewCell: JNWCollectionViewCell {

    override func setSelected(selected: Bool, animated animate: Bool) {
        self.layer?.borderColor = NSColor(calibratedRed: 0.104, green: 0.507, blue: 0.959, alpha: 1).CGColor;
        self.layer?.borderWidth = (selected == true) ? 4 : 0;
        self.layer?.cornerRadius = (selected == true) ? 2 : 0;
    }
    
    @objc func updateWithURL(url:NSURL){
        let request = NSURLRequest(URL: url)
        let requestOperation = AFHTTPRequestOperation(request: request)
        requestOperation.responseSerializer = AFImageResponseSerializer()
        
        requestOperation.setCompletionBlockWithSuccess({ (op: AFHTTPRequestOperation! , thing:AnyObject!) -> Void in
            self.backgroundImage = thing as NSImage
            
        }, failure: { (op:AFHTTPRequestOperation!, error:NSError!) -> Void in
            
            NSLog("Eroror");
        });

        requestOperation.start();
    }
}
