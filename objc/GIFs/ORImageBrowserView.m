//
//  ORImageBrowserView.m
//  GIFs
//
//  Created by Orta on 8/24/14.
//  Copyright (c) 2014 Orta Therox. All rights reserved.
//

#import "ORImageBrowserView.h"

static CGFloat const ORImageBrowserMargin = 3;

@implementation ORImageBrowserView

- (IKImageBrowserCell *) newCellForRepresentedItem:(id) cell
{
    return [[ORImageBrowserCell alloc] init];
}

@end

@implementation ORImageBrowserCell

- (NSRect)imageFrame
{
    return self.frame;
}

- (NSRect) selectionFrame
{
    return NSInsetRect([self frame], -ORImageBrowserMargin, -ORImageBrowserMargin);
}

- (CALayer *) layerForType:(NSString*) type
{
    NSRect frame = [self frame];
    
    if(type == IKImageBrowserCellSelectionLayer){
        
        CALayer *selectionLayer = [CALayer layer];
        selectionLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    
        NSColor *color = [NSColor selectedMenuItemColor];
        [selectionLayer setBorderColor:color.CGColor];
        
        [selectionLayer setBorderWidth:ORImageBrowserMargin];
        [selectionLayer setCornerRadius:0];
        
        return selectionLayer;
    }
    
    return [super layerForType:type];
}

@end