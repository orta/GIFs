//
//  ORDarkBlueView.m
//  GIFs
//
//  Created by Orta on 14/11/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "ORDarkBlueView.h"

@implementation ORDarkBlueView

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor colorWithCalibratedRed:0.150 green:0.140 blue:0.169 alpha:1.000] setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

@end
