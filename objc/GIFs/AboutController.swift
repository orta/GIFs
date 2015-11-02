//
//  AboutController.swift
//  GIFs
//
//  Created by Orta on 8/31/14.
//  Copyright (c) 2014 Orta Therox. All rights reserved.
//

import Foundation
import AppKit

class AboutController : NSObject {
    
    @IBOutlet weak var subtitleField: NSTextField!
    @IBOutlet weak var aboutWindow: NSWindow!
    @IBOutlet weak var mainWindow: NSWindow!
    @IBOutlet weak var backgroundImageView: NSImageView!
    
    @IBOutlet weak var titleBackgroundView: NSView!
    
    override func awakeFromNib() {
        titleBackgroundView.layer!.backgroundColor = NSColor(calibratedWhite: 0, alpha: 0.3).CGColor
    }
    
    @IBAction func openModal(sender: AnyObject) {
        
        let rando:UInt32 = arc4random_uniform(13)
        backgroundImageView.image = NSImage(named: "about\(rando)")
        
        mainWindow.beginSheet(aboutWindow, completionHandler:nil)
    }

    
    @IBAction func closeModal(sender: AnyObject) {
        mainWindow.endSheet(aboutWindow)
    }
    
    @IBAction func openGithub(sender: AnyObject) {
        let workspace = NSWorkspace.sharedWorkspace()
        workspace.openURL(NSURL(string: "http://github.com/orta")!);
    }
    
    @IBAction func openTwitter(sender: AnyObject) {
        let workspace = NSWorkspace.sharedWorkspace()
        if let _ = workspace.fullPathForApplication("Tweetbot") {
            workspace.openURL(NSURL(string: "tweetbot:///user_profile/orta")!);
            
        } else {
            workspace.openURL(NSURL(string: "http://twitter.com/orta")!);
        }
        
    }
    
    @IBAction func openMySite(sender: AnyObject) {
        let workspace = NSWorkspace.sharedWorkspace()
        workspace.openURL(NSURL(string: "http://orta.io")!);

    }
}
