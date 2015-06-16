//
//  ORGIFActionsController.h
//  GIFs
//
//  Created by Bryan Luby on 5/25/15.
//  Copyright (c) 2015 Orta Therox. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Helper class for shared contextual menu and keyboard shorcut actions on GIFs.
 */
@interface ORGIFActionsController : NSObject

+ (void)tweetOutLinkToURL:(NSURL *)url;

+ (void)tweetOrtaLinkToURL:(NSURL *)url;

+ (void)copyGIFDownloadURLToClipboard:(NSURL *)downloadURL;

+ (void)copyGIFMarkdownToClipboardWithSourceTitle:(NSString *)sourceTitle downloadURL:(NSURL *)downloadURL;

+ (void)openGIFDownloadURLInBrowser:(NSURL *)downloadURL;

+ (void)openGIFContextURLInBrowser:(NSURL *)contextURL;

+ (void)downloadGIFWithURL:(NSURL *)downloadURL completion:(void(^)(BOOL success, NSError *error))completion;

@end
