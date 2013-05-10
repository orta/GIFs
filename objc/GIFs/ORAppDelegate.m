//
//  ORAppDelegate.m
//  GIFs
//
//  Created by orta therox on 12/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "ORAppDelegate.h"

@implementation ORAppDelegate

static ORAppDelegate *_sharedInstance = nil;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _sharedInstance = self;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

+ (void)setNetworkActivity:(BOOL)activity {
    if (activity) {
        [_sharedInstance.networkProgress startAnimation:self];
    } else {
        [_sharedInstance.networkProgress stopAnimation:self];
    }
}

@end
