//
//  ORSharingController.h
//  GIFs
//
//  Created by orta therox on 20/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ORGIFAppViewController.h"
#import "GIF.h"
#import "DragDropImageView.h"

@interface ORSharingController : NSObject <NSSharingServiceDelegate, NSSharingServicePickerDelegate>

@property (weak) IBOutlet ORGIFAppViewController *gifController;
@property (unsafe_unretained) IBOutlet NSWindow *appWindow;

@property (weak) IBOutlet NSButton *emailButton;
@property (weak) IBOutlet NSButton *facebookButton;
@property (weak) IBOutlet NSButton *twitterButton;
@property (weak) IBOutlet NSButton *miscButton;
@property (weak) IBOutlet DragDropImageView *mainImageView;

@end
