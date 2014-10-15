//
//  ORWindowTitleDecorationController.swift
//  GIFs
//
//  Created by Orta on 8/7/14.
//  Copyright (c) 2014 Orta Therox. All rights reserved.
//

import Cocoa
import AppKit

@objc public class ORWindowTitleDecorationController: NSObject, NSSplitViewDelegate  {
   
    @IBOutlet weak var mainWindow: NSWindow!
    @IBOutlet weak var titleBlurView: NSView!
    @IBOutlet weak var sourceListSuperView: NSView!
    @IBOutlet weak var fakeRightSplitter: NSView!
    @IBOutlet weak var rightColumnView: NSView!

    @IBOutlet weak var itemTitle: NSTextField!
    @IBOutlet weak var sectionTitle: NSTextField!
    
    @IBOutlet weak var gridAndDetailSplitter: NSSplitView!
    
    @IBOutlet weak var giphyLogo: NSImageView!
    
    @objc public func showGiphyLogo(show:ObjCBool) {
        giphyLogo.hidden = !show.boolValue
    }
    
    override public func awakeFromNib() {
        (mainWindow.contentView as NSView).addSubview(self.titleBlurView);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateToolbarBlur", name: NSWindowDidResizeNotification, object: self.mainWindow)
        updateToolbarBlur()

        giphyLogo.animates = true
        
        var path = NSBundle.mainBundle().pathForResource("Giphy_API_Logo_ForWhite_Trans", ofType: "gif")!
        giphyLogo.image = NSImage(contentsOfFile: path)

    }
        
    public func splitView(splitView: NSSplitView!, constrainMinCoordinate proposedMinimumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        return (splitView == self.fakeRightSplitter && dividerIndex == 0) ? 180 : proposedMinimumPosition;
    }
    
    public func splitView(splitView: NSSplitView!, constrainMaxCoordinate proposedMaximumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        return (splitView == self.fakeRightSplitter && dividerIndex == 0) ? 240 : proposedMaximumPosition;
    }
    
    public func splitView(splitView: NSSplitView!, constrainSplitPosition proposedPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        self.updateToolbarBlur();
        return proposedPosition;
    }
    
    func updateToolbarBlur(){
        let windowFrame = self.titleBlurView.window?.frame
        let leftColumnWidth = CGRectGetWidth(self.sourceListSuperView.frame)
        let titleWidth  = CGRectGetWidth(windowFrame!) - leftColumnWidth
        let titleHeight = CGRectGetHeight(self.titleBlurView.bounds)
        let rightColumnWidth = CGRectGetWidth(self.rightColumnView.frame)

        self.titleBlurView.frame = CGRectMake(leftColumnWidth, CGRectGetHeight(windowFrame!) - titleHeight + 1, titleWidth , titleHeight);
        
        self.fakeRightSplitter.frame = CGRectMake(titleWidth - rightColumnWidth, 0, 1, titleHeight)
        
        self.itemTitle.frame = CGRectMake(titleWidth - rightColumnWidth + 2, 18, rightColumnWidth , 18);
        
        self.sectionTitle.frame = CGRectMake(0,  18, titleWidth - rightColumnWidth, 18);
    }
}
