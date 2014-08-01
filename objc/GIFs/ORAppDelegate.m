//
//  ORAppDelegate.m
//  GIFs
//
//  Created by orta therox on 12/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "ORAppDelegate.h"
#import "ORMenuController.h"

@implementation ORAppDelegate

static ORAppDelegate *_sharedInstance = nil;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _sharedInstance = self;

    self.window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
    self.window.styleMask = self.window.styleMask | NSFullSizeContentViewWindowMask;
    self.window.titleVisibility = NSWindowTitleHiddenWhenActive;
    self.window.titlebarAppearsTransparent = YES;
    self.window.movableByWindowBackground = YES;

    [self.menuController.menuTableView reloadData];
    [self.menuController.menuTableView selectTopItem];
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
