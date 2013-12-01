//
//  ORAppDelegate.h
//  GIFs
//
//  Created by orta therox on 12/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ORMenuController;
@interface ORAppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSProgressIndicator *networkProgress;
@property (assign) IBOutlet NSWindow *window;
@property (strong) IBOutlet ORMenuController *menuController;

+ (void)setNetworkActivity:(BOOL)activity;

@end
