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

@class GIF, ORRedditImageController, ORSearchController, ORTumblrController;
@protocol ORGIFSource <NSObject>

- (void)getNextGIFs;
- (NSInteger)numberOfGifs;
- (GIF *)gifAtIndex:(NSInteger)index;

@end

@interface ORGIFAppViewController : NSObject

@property (weak) IBOutlet NSScrollView *imageScrollView;

@property (weak) IBOutlet IKImageBrowserView *imageBrowser;
@property (weak) IBOutlet NSImageView *imageView;

@property (strong) GIF *currentGIF;

- (void)gotNewGIFs;

- (void)getGIFsFromSourceString:(NSString *)string;

- (NSString *)gifFilePath;

@end
