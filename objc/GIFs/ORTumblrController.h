//
//  ORTumblrController.h
//  GIFs
//
//  Created by orta therox on 21/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ORGIFController.h"

@class GIF;

@interface ORTumblrController : NSObject <ORGIFSource>
- (void)setTumblrURL:(NSString *)tumblrURL;

@property (weak) IBOutlet ORGIFController *gifController;
@end
