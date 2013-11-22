//
//  ORMenuController.h
//  GIFs
//
//  Created by orta therox on 12/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ORGIFController.h"
#import "ORSimpleSourceListView.h"

@interface ORMenuController : NSObject <ORSourceListDataSource, ORSourceListDelegate, NSTextFieldDelegate, NSSplitViewDelegate>

@property (weak) IBOutlet ORGIFController *gifViewController;
@property (weak) IBOutlet ORSimpleSourceListView *menuTableView;
@property (unsafe_unretained) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSView *windowToolbar;
@property (weak) IBOutlet NSSplitView *mainSplitView;

- (void)addNewSubreddit:(NSString *)subreddit;
- (void)addNewTumblr:(NSString *)tumblr;

@end
