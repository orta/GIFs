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
#import <GIFKit/ORGIFSource.h>
#import "ORImageBrowserView.h"

@class GIF, ORSubredditNetworkModel, ORGiphyNetworkModel, ORTumblrController, ORStarredSourceController, ORMenuController;

@interface ORGIFController : NSObject <ORImageBrowserViewDelegate>

@property (weak) IBOutlet IKImageBrowserView *collectionView;

@property (weak) IBOutlet WebView *webView;
@property (weak) IBOutlet NSButton *openGIFContextButton;

@property (weak) IBOutlet NSPopover *createSourcePopover;

@property (weak) IBOutlet NSProgressIndicator *downloadProgressIndicator;

@property (weak) IBOutlet ORSubredditNetworkModel *redditController;
@property (weak) IBOutlet ORGiphyNetworkModel *searchController;
@property (weak) IBOutlet ORTumblrController *tumblrController;
@property (weak) IBOutlet ORStarredSourceController *starredController;
@property (weak) IBOutlet ORMenuController *menuController;

@property (weak) IBOutlet NSTextField *sectionTitle;
@property (weak) IBOutlet NSTextField *gifTitle;

@property (strong) GIF *currentGIF;

- (void)gotNewGIFs;

- (void)getGIFsFromSourceString:(NSString *)string;

- (NSString *)gifFilePath;

- (IBAction)openCurrentGIF:(NSButton *)sender;

@end
