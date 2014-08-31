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

@class ORStarredSourceController;

@interface ORMenuController : NSObject <ORSourceListDataSource, ORSourceListDelegate, NSTextFieldDelegate>

@property (weak) IBOutlet ORGIFController *gifViewController;
@property (weak) IBOutlet ORSimpleSourceListView *menuTableView;
@property (weak) IBOutlet ORStarredSourceController *starredController;

@property (unsafe_unretained) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSView *windowToolbar;
@property (weak) IBOutlet NSSplitView *mainSplitView;

@property (weak) IBOutlet NSSearchField *searchBar;

- (IBAction)makeSearchFieldFirstResponder:(id)sender;
- (void)addNewSubreddit:(NSString *)subreddit;
- (void)addNewTumblr:(NSString *)tumblr;

@end
