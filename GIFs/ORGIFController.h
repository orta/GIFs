//
//  ORGIFController.h
//  GIFs
//
//  Created by orta therox on 13/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
#import <WebKit/WebKit.h>

@class GIF, ORRedditImageController, ORSearchController;
@protocol ORGIFSource <NSObject>

- (void)getNextGIFs;
- (NSInteger)numberOfGifs;
- (GIF *)gifAtIndex:(NSInteger)index;

@end

@interface ORGIFController : NSObject

@property (weak) IBOutlet NSScrollView *imageScrollView;

@property (weak) IBOutlet WebView *webView;
@property (weak) IBOutlet IKImageBrowserView *imageBrowser;

@property (weak) IBOutlet ORRedditImageController *redditController;
@property (weak) IBOutlet ORSearchController *searchController;

- (void)gotNewGIFs;

- (void)getGIFsFromSourceString:(NSString *)string;

@end
