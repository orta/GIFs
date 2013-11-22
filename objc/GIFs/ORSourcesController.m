//
//  ORSourcesController.m
//  GIFs
//
//  Created by Orta on 14/11/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "ORSourcesController.h"
#import <AFNetworking/AFNetworking.h>

@implementation ORSourcesController

- (IBAction)tumblrTextfieldChanged:(NSTextField *)sender {

    NSString *path = [NSString stringWithFormat:@"%@/api/read/json", sender.stringValue];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:path]];
    NSLog(@"%@", path);

    AFHTTPRequestOperation *requestOp = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [requestOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.tumblrSaveButton.image = [NSImage imageNamed:@"tick_active"];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.tumblrSaveButton.image = [NSImage imageNamed:@"tick"];

    }];
    [requestOp start];
}

- (IBAction)tumblrSavedTapped:(id)sender {
    [self.menuController addNewTumblr:self.tumblrURLTextField.stringValue];
    [self.sourcePopover performClose:self];
}

- (IBAction)redditTextFieldChanged:(NSTextField *)sender {

    NSString *path = [NSString stringWithFormat:@"http://www.reddit.com%@.json", sender.stringValue];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:path]];
    AFHTTPRequestOperation *requestOp = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [requestOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.redditSaveButton.image = [NSImage imageNamed:@"tick_active"];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.redditSaveButton.image = [NSImage imageNamed:@"tick"];
    }];
    [requestOp start];
}

- (IBAction)redditSaveTapped:(id)sender {
    [self.menuController addNewSubreddit:self.redditTextField.stringValue];
    [self.sourcePopover performClose:self];
}

@end
