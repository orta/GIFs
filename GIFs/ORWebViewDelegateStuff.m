//
//  ORWebViewDelegateStuff.m
//  GIFs
//
//  Created by orta therox on 12/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "ORWebViewDelegateStuff.h"

@implementation ORWebViewDelegateStuff

- (void)awakeFromNib {
    _webView.UIDelegate = self;
}

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems {
    return nil;
}

@end
