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
    NSRect imageFrame = [super imageFrame];
    
    if (NSIsEmptyRect(imageFrame)) {
        return NSZeroRect;
    }
    
    CGFloat aspectRatio =  imageFrame.size.width / imageFrame.size.height;
    
    if (aspectRatio == 1.0f) {
        return imageFrame;
    }
    
    NSRect containerFrame = [self imageContainerFrame];
    
    if (NSIsEmptyRect(containerFrame)) {
        return NSZeroRect;
    }
    
    CGFloat containerAspectRatio = containerFrame.size.width / containerFrame.size.height;
    
    if (containerAspectRatio > aspectRatio) {
        imageFrame.size.height = containerFrame.size.height;
        imageFrame.origin.y = containerFrame.origin.y;
        imageFrame.size.width = imageFrame.size.height * aspectRatio;
        imageFrame.origin.x = containerFrame.origin.x + (containerFrame.size.width - imageFrame.size.width) / 2.0f;
    } else {
        imageFrame.size.width = containerFrame.size.width;
        imageFrame.origin.x = containerFrame.origin.x;
        imageFrame.size.height = imageFrame.size.width / aspectRatio;
        imageFrame.origin.y = containerFrame.origin.y + (containerFrame.size.height - imageFrame.size.height) / 2.0f;
    }
    
    return imageFrame;
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