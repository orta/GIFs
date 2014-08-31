//
//  ORGIFRightClickMenuMaker.m
//  GIFs
//
//  Created by Orta on 8/20/14.
//  Copyright (c) 2014 Orta Therox. All rights reserved.
//

#import "ORGIFRightClickMenuMaker.h"
#import <AFNetworking/AFNetworking.h>

@interface ORGIFRightClickMenuMaker()<NSSharingServiceDelegate>
@property (readonly, nonatomic, copy) NSArray *sharingServices;

@end

@implementation ORGIFRightClickMenuMaker

- (instancetype)initWithGIF:(GIF *)gif
{
    self = [super init];
    if (!self) return nil;
    
    _gif = gif;
    
    return self;
}

- (NSMenu *)menu;
{
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"menu"];
    [menu setAutoenablesItems:NO];
    
    for (NSMenuItem *item in [self menuItems]) {
        [menu addItem:item];
    }
    return menu;
}

- (NSArray *)menuItems
{
    NSMutableArray *menuItems = [NSMutableArray array];
    
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Copy GIF URL to Clipboard" action: @selector(copyURL) keyEquivalent:@"c"];
    [item setTarget:self];
    [menuItems addObject:item];
    
    item = [[NSMenuItem alloc] initWithTitle:@"Copy Image Markdown" action: @selector(copyMarkdown) keyEquivalent:@"C"];
    [item setTarget:self];
    [menuItems addObject:item];
    
    [menuItems addObject:[NSMenuItem separatorItem]];
    item = [[NSMenuItem alloc] initWithTitle:@"Open GIF in Browser" action:@selector(openInBrowser) keyEquivalent:@"b"];
    item.target = self;
    [menuItems addObject:item];
    
    if (self.gif.sourceURL) {
        item = [[NSMenuItem alloc] initWithTitle:@"Open GIF Context" action:@selector(openContext) keyEquivalent:@"o"];
        item.target = self;
        [menuItems addObject:item];
    }
    
    [menuItems addObject:[NSMenuItem separatorItem]];
    item = [[NSMenuItem alloc] initWithTitle:@"Download GIF" action:@selector(downloadGIF) keyEquivalent:@"s"];
    item.target = self;
    [menuItems addObject:item];
    
    [menuItems addObject:[NSMenuItem separatorItem]];
    
    NSArray *sharingServiceIDs = @[NSSharingServiceNamePostOnFacebook, NSSharingServiceNamePostOnTwitter, NSSharingServiceNamePostOnSinaWeibo, NSSharingServiceNamePostOnTencentWeibo, NSSharingServiceNamePostOnLinkedIn, NSSharingServiceNameComposeEmail, NSSharingServiceNameComposeMessage];
    
    _sharingServices = [NSSharingService sharingServicesForItems:sharingServiceIDs];
    for (NSSharingService *currentService in self.sharingServices) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:currentService.title action:@selector(share:) keyEquivalent:@""];
        item.image = currentService.image;
        item.representedObject = currentService;
        item.target = self;
        
        currentService.delegate = self;
        [menuItems addObject:item];
    }

    return [NSArray arrayWithArray:menuItems];
    
}

- (void)share:(NSMenuItem *)share
{
    NSSharingService *service = share.representedObject;
    [service performWithItems:@[@"", self.gif.downloadURL]];
}

- (void)downloadGIF
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    savePanel.allowedFileTypes = @[@"gif"];
    savePanel.canCreateDirectories = YES;
    savePanel.allowsOtherFileTypes = NO;
    savePanel.canSelectHiddenExtension = YES;
    
    NSString *downloadDirectoryPath = [ NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES) firstObject];
    NSURL *downloadDirectoryURL = [NSURL fileURLWithPath:downloadDirectoryPath];
    savePanel.directoryURL = self.lastUserSelectedDirectory ? self.lastUserSelectedDirectory : downloadDirectoryURL;
    savePanel.nameFieldStringValue = self.gif.downloadURL.lastPathComponent;
    
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:self.gif.downloadURL];
    AFHTTPRequestOperation *afhttpRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [afhttpRequestOperation
     setDownloadProgressBlock:^(NSUInteger bytesRead, long long int totalBytesRead, long long int totalBytesExpectedToRead) {
//         [self.downloadProgressIndicator setIndeterminate:NO];
//         double doubleValue = (double) totalBytesRead / totalBytesExpectedToRead * 100.0;
//         [self.downloadProgressIndicator setDoubleValue:doubleValue];
     }];
    
    [savePanel beginWithCompletionHandler:^(NSInteger result) {
        if (result) {
            self.lastUserSelectedDirectory = savePanel.directoryURL;
//            [self.downloadProgressIndicator setHidden:NO];
            
            [afhttpRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSData * responseObject) {
                BOOL success = [responseObject writeToURL:savePanel.URL atomically:YES];
                if (!success) {
                    NSLog(@"Failed to write file");
                }
//                [self.downloadProgressIndicator stopAnimation:nil];
//                [self.downloadProgressIndicator setHidden:YES];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error)
             {
                 NSLog(@"Fetch failed\n %@ \n %@", operation, error);
             }];
            
//            [self.downloadProgressIndicator startAnimation:nil];
            [afhttpRequestOperation start];
        }
    }];
}

- (void)copyURL
{
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] writeObjects:@[self.gif.downloadURL]];
}

- (void)copyMarkdown
{
    [[NSPasteboard generalPasteboard] clearContents];
    NSString *markdown = [NSString stringWithFormat:@"![%@](%@)", self.gif.sourceTitle, self.gif.downloadURL];
    [[NSPasteboard generalPasteboard] writeObjects:@[markdown]];
}

- (void)openInBrowser
{
    [[NSWorkspace sharedWorkspace] openURL:self.gif.downloadURL];
}

- (void)openContext
{
    [[NSWorkspace sharedWorkspace] openURL:self.gif.sourceURL];
}



@end
