//
//  ORWebViewDelegateStuff.m
//  GIFs
//
//  Created by orta therox on 12/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "ORWebViewDelegateStuff.h"

@implementation ORWebViewDelegateStuff {
    NSURL *currentAddress;
}

- (void)awakeFromNib {
    _webView.UIDelegate = self;
}

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems {
    if (element[WebElementImageURLKey]) {

        currentAddress = element[WebElementImageURLKey];
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Copy URL" action:@selector(copyURL) keyEquivalent:@""];
        item.target = self;

        return @[item];
    }
    
    return defaultMenuItems;
}

- (void)copyURL {
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] writeObjects:@[currentAddress]];
}

@end
