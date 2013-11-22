//
//  ORSourcesController.h
//  GIFs
//
//  Created by Orta on 14/11/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ORMenuController.h"

@interface ORSourcesController : NSObject

@property (nonatomic, weak) IBOutlet ORMenuController *menuController;
@property (nonatomic, weak) IBOutlet NSPopover *sourcePopover;

@property (weak) IBOutlet NSTextField *tumblrURLTextField;
@property (weak) IBOutlet NSButton *tumblrSaveButton;

- (IBAction)tumblrTextfieldChanged:(NSTextField *)sender;
- (IBAction)tumblrSavedTapped:(id)sender;


@property (weak) IBOutlet NSTextField *redditTextField;
@property (weak) IBOutlet NSButton *redditSaveButton;

- (IBAction)redditTextFieldChanged:(NSTextField *)sender;

- (IBAction)redditSaveTapped:(id)sender;

@end
