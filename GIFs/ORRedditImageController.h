//
//  ORRedditImageController.h
//  GIFs
//
//  Created by orta therox on 12/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ORGIFAppViewController.h"

@class GIF;
@interface ORRedditImageController : NSObject <ORGIFSource>

- (void)setRedditURL:(NSString *)redditURL;
@property (weak) IBOutlet ORGIFAppViewController *gifController;

@end
