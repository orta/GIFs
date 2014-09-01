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
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.titlebarAppearsTransparent = YES;
    self.window.movableByWindowBackground = YES;

    // They get cropped
    // [self moveTitleBarButtons];
    
    [self.menuController.menuTableView reloadData];
    [self.menuController.menuTableView selectDefaultItem];
}

- (void)moveTitlebarButtons
{
    
    NSButton *closeButton = [self.window standardWindowButton:NSWindowCloseButton];
    NSButton *zoomButton = [self.window standardWindowButton:NSWindowZoomButton];
    NSButton *minimizeButton = [self.window standardWindowButton:NSWindowMiniaturizeButton];
    
    closeButton.frame = NSMakeRect(closeButton.frame.origin.x+5,
                                   closeButton.frame.origin.y-12,
                                   closeButton.frame.size.height,
                                   closeButton.frame.size.width);
    
    zoomButton.frame = NSMakeRect(zoomButton.frame.origin.x+5,
                                  zoomButton.frame.origin.y-12,
                                  zoomButton.frame.size.height,
                                  zoomButton.frame.size.width);
    
    minimizeButton.frame = NSMakeRect(minimizeButton.frame.origin.x+5,
                                      minimizeButton.frame.origin.y-12,
                                      minimizeButton.frame.size.height,
                                      minimizeButton.frame.size.width);
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

+ (void)setNetworkActivity:(BOOL)activity
{
    if (activity) {
        [_sharedInstance.networkProgress startAnimation:self];
    } else {
        [_sharedInstance.networkProgress stopAnimation:self];
    }
}

@end
