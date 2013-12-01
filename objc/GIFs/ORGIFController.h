//
//  ORGIFController.h
//  GIFs
//
//  Created by orta therox on 13/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
#import "ORSimpleSourceListView.h"
#import <WebKit/WebKit.h>

@class GIF, ORRedditImageController, ORSearchController, ORTumblrController, ORStarredSourceController, ORMenuController;
@protocol ORGIFSource <NSObject>

- (void)getNextGIFs;
- (NSInteger)numberOfGifs;
- (GIF *)gifAtIndex:(NSInteger)index;

@end

@interface ORGIFController : NSObject

@property (weak) IBOutlet NSScrollView *imageScrollView;

@property (weak) IBOutlet IKImageBrowserView *imageBrowser;
@property (weak) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet WebView *webView;

@property (weak) IBOutlet NSPopover *createSourcePopover;

@property (weak) IBOutlet ORRedditImageController *redditController;
@property (weak) IBOutlet ORSearchController *searchController;
@property (weak) IBOutlet ORTumblrController *tumblrController;
@property (weak) IBOutlet ORStarredSourceController *starredController;
@property (weak) IBOutlet ORMenuController *menuController;

@property (strong) GIF *currentGIF;

- (void)gotNewGIFs;

- (void)getGIFsFromSourceString:(NSString *)string;

- (void)getGIFsFromStarred;

- (NSString *)gifFilePath;

@end
