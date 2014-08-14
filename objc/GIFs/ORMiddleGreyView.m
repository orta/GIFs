//
//  ORMiddleGreyView.m
//  GIFs
//
//  Created by Orta on 8/13/14.
//  Copyright (c) 2014 Orta Therox. All rights reserved.
//

#import "ORMiddleGreyView.h"

@implementation ORMiddleGreyView

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor colorWithCalibratedRed:0.769 green:0.755 blue:0.756 alpha:1.000] setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}


@end
