//
//  ORGIFActionsController.m
//  GIFs
//
//  Created by Bryan Luby on 5/25/15.
//  Copyright (c) 2015 Orta Therox. All rights reserved.
//

#import "ORGIFActionsController.h"
#import <AFNetworking/AFHTTPRequestOperation.h>
#import <STTwitter/STTwitter.h>
#import <Keys/GIFsKeys.h>

@implementation ORGIFActionsController

+ (void)tweetOrtaLinkToURL:(NSURL *)url
{
    NSString *tweet = [NSString stringWithFormat:@"@orta - %@", url.absoluteString];
    [self tweet:tweet];
}

+ (void)tweetOutLinkToURL:(NSURL *)url
{
    NSString *tweet = [NSString stringWithFormat:@"%@", url.absoluteString];
    [self tweet:tweet];
}

+ (void)tweet:(NSString *)tweet
{
    GIFsKeys *keys = [[GIFsKeys alloc] init];
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey: [keys randoTwitterBotConsumerKey]
                                                          consumerSecret: [keys randoTwitterBotConsumerSecret]
                                                              oauthToken: [keys randoTwitterBotOAuthToken]
                                                        oauthTokenSecret: [keys randoTwitterBotOAuthTokenSecret]];

    [twitter postStatusUpdate:tweet inReplyToStatusID:nil latitude:nil longitude:nil placeID:@"GIFS.app" displayCoordinates:nil trimUser:@0 successBlock:^(NSDictionary *status) {

    } errorBlock:^(NSError *error) {

    }];
}

+ (void)copyGIFDownloadURLToClipboard:(NSURL *)downloadURL
{
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] writeObjects:@[downloadURL.absoluteString]];
}

+ (void)copyGIFMarkdownToClipboardWithSourceTitle:(NSString *)sourceTitle downloadURL:(NSURL *)downloadURL
{
    [[NSPasteboard generalPasteboard] clearContents];
    NSString *markdown = [NSString stringWithFormat:@"![%@](%@)", sourceTitle, downloadURL];
    [[NSPasteboard generalPasteboard] writeObjects:@[markdown]];
}

+ (void)openGIFDownloadURLInBrowser:(NSURL *)downloadURL
{
    [self openURL:downloadURL];
}

+ (void)openGIFContextURLInBrowser:(NSURL *)contextURL
{
    [self openURL:contextURL];
}

+ (void)openURL:(NSURL *)URL
{
    [[NSWorkspace sharedWorkspace] openURL:URL];
}

+ (void)downloadGIFWithURL:(NSURL *)downloadURL completion:(void(^)(BOOL success, NSError *error))completion
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    savePanel.allowedFileTypes = @[@"gif"];
    savePanel.canCreateDirectories = YES;
    savePanel.allowsOtherFileTypes = NO;
    savePanel.canSelectHiddenExtension = YES;
    
    NSString *downloadDirectoryPath = [ NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES) firstObject];
    NSURL *downloadDirectoryURL = [NSURL fileURLWithPath:downloadDirectoryPath];
    static NSURL * lastUserSelectedDirectoryURL = nil;
    savePanel.directoryURL = lastUserSelectedDirectoryURL ? lastUserSelectedDirectoryURL : downloadDirectoryURL;
    savePanel.nameFieldStringValue = downloadURL.lastPathComponent;
    
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:downloadURL];
    AFHTTPRequestOperation *afhttpRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [afhttpRequestOperation
     setDownloadProgressBlock:^(NSUInteger bytesRead, long long int totalBytesRead, long long int totalBytesExpectedToRead) {
         
     }];
    
    [savePanel beginWithCompletionHandler:^(NSInteger result) {
        if (result) {
            lastUserSelectedDirectoryURL = savePanel.directoryURL;
            
            [afhttpRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSData *responseObject) {
                BOOL success = [responseObject writeToURL:savePanel.URL atomically:YES];

                NSError *error;
                if (!success) {
                    NSString *errorString = NSLocalizedString(@"Failed to save file", @"Failed to save file");
                    error = [NSError errorWithDomain:NSCocoaErrorDomain
                                                code:NSFileWriteUnknownError
                                            userInfo:@{NSLocalizedDescriptionKey: errorString}];
                    NSLog(@"%@", errorString);
                } else {
                    NSLog(@"Successfully downloaded file.");
                }
                
                if (completion) {
                    completion(success, error);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Fetch failed\n %@ \n %@", operation, error);
                
                if (completion) {
                    completion(NO, error);
                }
            }];

            [afhttpRequestOperation start];
        }
    }];
}

@end
