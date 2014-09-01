//
//  ORWindowDraggableVisualEffectsView.m
//  GIFs
//
//  Created by Orta on 8/20/14.
//  Copyright (c) 2014 Orta Therox. All rights reserved.
//

#import "ORWindowDraggableVisualEffectsView.h"

@interface ORWindowDraggableVisualEffectsView()
@property (assign) NSPoint initialLocation;
@end

@implementation ORWindowDraggableVisualEffectsView

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    self.initialLocation = [theEvent locationInWindow];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    
    NSRect screenVisibleFrame = [self.window.screen visibleFrame];
    NSRect windowFrame = [self.window frame];
    NSPoint newOrigin = windowFrame.origin;
    
    // Get the mouse location in window coordinates.
    NSPoint currentLocation = [theEvent locationInWindow];
    // Update the origin with the difference between the new mouse location and the old mouse location.
    newOrigin.x += (currentLocation.x - self.initialLocation.x);
    newOrigin.y += (currentLocation.y - self.initialLocation.y);
    
    // Don't let window get dragged up under the menu bar
    if ((newOrigin.y + windowFrame.size.height) > (screenVisibleFrame.origin.y + screenVisibleFrame.size.height)) {
        newOrigin.y = screenVisibleFrame.origin.y + (screenVisibleFrame.size.height - windowFrame.size.height);
    }
    
    // Move the window to the new location
    [self.window setFrameOrigin:newOrigin];
}


@end
