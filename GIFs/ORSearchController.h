//
//  ORSearchController.h
//  GIFs
//
//  Created by orta therox on 13/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ORGIFController.h"

@interface ORSearchController : NSObject <ORGIFSource>

- (void)setSearchQuery:(NSString *)query;

@end
