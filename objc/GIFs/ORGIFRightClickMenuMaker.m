//
//  ORGIFRightClickMenuMaker.m
//  GIFs
//
//  Created by Orta on 8/20/14.
//  Copyright (c) 2014 Orta Therox. All rights reserved.
//

#import "ORGIFRightClickMenuMaker.h"
#import "ORGIFActionsController.h"

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
    item = [[NSMenuItem alloc] initWithTitle:@"Post to @RandoGIFs" action:@selector(postToRando) keyEquivalent:@"r"];
    item.target = self;
    [menuItems addObject:item];

    item = [[NSMenuItem alloc] initWithTitle:@"Send to @orta" action:@selector(postToOrta) keyEquivalent:@"O"];
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


- (void)postToOrta
{
    [ORGIFActionsController tweetOrtaLinkToURL:self.gif.downloadURL];
}

- (void)postToRando
{
    [ORGIFActionsController tweetOutLinkToURL:self.gif.downloadURL];
}

- (void)downloadGIF
{
    [ORGIFActionsController downloadGIFWithURL:self.gif.downloadURL completion:nil];
}

- (void)copyURL
{
    [ORGIFActionsController copyGIFDownloadURLToClipboard:self.gif.downloadURL];
}

- (void)copyMarkdown
{
    [ORGIFActionsController copyGIFMarkdownToClipboardWithSourceTitle:self.gif.sourceTitle
                                                          downloadURL:self.gif.downloadURL];
}

- (void)openInBrowser
{
    [ORGIFActionsController openGIFDownloadURLInBrowser:self.gif.downloadURL];
}

- (void)openContext
{
    [ORGIFActionsController openGIFContextURLInBrowser:self.gif.sourceURL];
}

@end
