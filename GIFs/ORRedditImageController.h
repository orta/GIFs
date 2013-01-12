//
//  ORRedditImageController.h
//  GIFs
//
//  Created by orta therox on 12/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
#import <WebKit/WebKit.h>

@interface ORRedditImageController : NSObject 

- (void)setRedditURL:(NSString *)redditURL;
@property (weak) IBOutlet NSScrollView *imageScrollView;

@property (weak) IBOutlet WebView *webView;
@property (weak) IBOutlet IKImageBrowserView *imageBrowser;

@end
