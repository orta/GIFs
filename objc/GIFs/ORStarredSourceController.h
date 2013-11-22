//
//  ORStarredSourceController.h
//  GIFs
//
//  Created by Orta on 21/11/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ORGIFController.h"

@class GIF;

@interface ORStarredSourceController : NSObject <ORGIFSource>

@property (weak) IBOutlet ORGIFController *gifController;
- (void)reloadData;

@end
