//
//  ORWebViewDelegateStuff.m
//  GIFs
//
//  Created by orta therox on 12/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "ORWebViewDelegateStuff.h"
#import "ORGIFRightClickMenuMaker.h"
#import "ORGIFController.h"

@implementation ORWebViewDelegateStuff {
    NSURL *currentAddress;
    ORGIFRightClickMenuMaker *menuMaker;
}

- (void)awakeFromNib {
    _webView.UIDelegate = self;
}

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems {

    NSMenuItem *copy = nil;
    for (NSMenuItem *item in defaultMenuItems) {
        // I want Copy Image, but I can't look at title due to localisation stuff
        if (item.tag == 6) {
            copy = item;
        }
    }

    GIF *gif = self.gifController.currentGIF;
    if (gif) {
        menuMaker = [[ORGIFRightClickMenuMaker alloc] initWithGIF:gif];
        return [menuMaker menuItemsWithImageCopyItem:copy];
    }
    return @[];
}


@end
