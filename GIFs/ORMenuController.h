//
//  ORMenuController.h
//  GIFs
//
//  Created by orta therox on 12/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ORGIFController.h"

@interface ORMenuController : NSObject <NSTableViewDataSource, NSTableViewDelegate>
@property (weak) IBOutlet ORGIFController *gifViewController;

@end
