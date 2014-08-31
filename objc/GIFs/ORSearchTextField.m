//
//  ORSearchTextField.m
//  GIFs
//
//  Created by Orta on 8/31/14.
//  Copyright (c) 2014 Orta Therox. All rights reserved.
//

#import "ORSearchTextField.h"

@implementation ORSearchTextField

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor colorWithCalibratedRed:0.150 green:0.140 blue:0.169 alpha:1.000] setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

@end
