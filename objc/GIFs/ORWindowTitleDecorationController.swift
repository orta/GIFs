//
//  ORWindowTitleDecorationController.swift
//  GIFs
//
//  Created by Orta on 8/7/14.
//  Copyright (c) 2014 Orta Therox. All rights reserved.
//

import Cocoa

class ORWindowTitleDecorationController: NSObject, NSSplitViewDelegate  {
   
    @IBOutlet weak var mainWindow: NSWindow!
    @IBOutlet weak var titleBlurView: NSView!
    @IBOutlet weak var sourceListSuperView: NSView!
    @IBOutlet weak var fakeRightSplitter: NSView!
    @IBOutlet weak var rightColumnView: NSView!
    
    @IBOutlet weak var gridAndDetailSplitter: NSSplitView!
    
    override func awakeFromNib() {
        mainWindow.contentView.addSubview(self.titleBlurView);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateToolbarBlur", name: NSWindowDidResizeNotification, object: self.mainWindow)
    }
    
    func splitView(splitView: NSSplitView!, constrainMinCoordinate proposedMinimumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        return (splitView == self.fakeRightSplitter && dividerIndex == 0) ? 180 : proposedMinimumPosition;
    }
    
    func splitView(splitView: NSSplitView!, constrainMaxCoordinate proposedMaximumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        return (splitView == self.fakeRightSplitter && dividerIndex == 0) ? 240 : proposedMaximumPosition;
    }
    
    func splitView(splitView: NSSplitView!, constrainSplitPosition proposedPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        self.updateToolbarBlur();
        return proposedPosition;
    }
    
    func updateToolbarBlur(){
        let windowFrame = self.titleBlurView.window?.frame
        let leftColumnWidth = CGRectGetWidth(self.sourceListSuperView.frame)
        let titleWidth  = CGRectGetWidth(windowFrame!) - leftColumnWidth
        let titleHeight = CGRectGetHeight(self.titleBlurView.bounds)
        
        self.titleBlurView.frame = CGRectMake(leftColumnWidth, CGRectGetHeight(windowFrame!) - titleHeight + 1, titleWidth , titleHeight);
        
        let rightColumnWidth = CGRectGetWidth(self.rightColumnView.frame)
        
        self.fakeRightSplitter.frame = CGRectMake(titleWidth - rightColumnWidth, 0, 1, titleHeight)
    }
}
