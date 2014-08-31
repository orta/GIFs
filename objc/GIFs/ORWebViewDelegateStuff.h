//
//  ORWebViewDelegateStuff.h
//  GIFs
//
//  Created by orta therox on 12/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@class ORGIFController;
@interface ORWebViewDelegateStuff : NSObject 
@property (weak) IBOutlet WebView *webView;
@property (weak) IBOutlet ORGIFController *gifController;
@end
