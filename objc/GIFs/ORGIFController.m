//
//  ORGIFController.m
//  GIFs
//
//  Created by orta therox on 13/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "ORGIFController.h"
#import <GIFKit/ORRedditSearchNetworkModel.h>
#import <GIFKit/ORSubredditNetworkModel.h>
#import "ORTumblrController.h"
#import "ORStarredSourceController.h"
#import "GIF.h"
#import "AFNetworking.h"
#import <StandardPaths/StandardPaths.h>
#import "NSString+StringBetweenStrings.h"
#import "ORMenuController.h"

@interface GIF()
@property (nonatomic, strong, readwrite) NSDate *dateAdded;
@end

@interface ORGIFController ()
@property(nonatomic, copy) NSURL *userSelectedDirectory;
@end

@implementation ORGIFController {
    NSObject <ORGIFSource> *_currentSource;
    NSSet *_starred;
    NSString *_gifPath;
}

- (void)getGIFsFromSourceString:(NSString *)string {
    if([string rangeOfString:@"reddit"].location != NSNotFound){
        _currentSource = _redditController;
        [_redditController setSubreddit:string];
    }

    else if([string rangeOfString:@".tumblr"].location != NSNotFound){
        _currentSource = _tumblrController;
        [_tumblrController setTumblrURL:string];

    } else if([string isEqualToString:@"STARRED"]){
        _currentSource = _starredController;
        _starredController.gifController = self;
        [_starredController reloadData];

    } else {
        _currentSource = _searchController;
        [_searchController setSearchQuery:string];
    }
    
    [self getNextGIFs];
    [_imageBrowser reloadData];
}

- (void)awakeFromNib {
    [_imageBrowser setValue:[NSColor colorWithCalibratedRed:0.955 green:0.950 blue:0.970 alpha:1.000] forKey:IKImageBrowserBackgroundColorKey];
    [[_imageBrowser superview] setPostsBoundsChangedNotifications:YES];

    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myTableClipBoundsChanged:)
                                                 name:NSViewBoundsDidChangeNotification object:[_imageBrowser superview]];

    [self loadStarred];
}

- (void)loadStarred {
    NSString *path = [[NSFileManager defaultManager] pathForPrivateFile:@"starred.data"];
    NSSet *data = [NSKeyedUnarchiver unarchiveObjectWithFile:path];

    if (!data) data = [NSSet set];
    _starred = [data mutableCopy];
}

- (void)saveStarred {
    NSString *path = [[NSFileManager defaultManager] pathForPrivateFile:@"starred.data"];
    [NSKeyedArchiver archiveRootObject:_starred toFile:path];
}

- (void)handleURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
    NSString *appleURL = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSString *download = [appleURL substringBetween:@"?dl=" and:@"***thumb"];
    NSString *thumbnail = [appleURL substringBetween:@"***thumb" and:@"&***source"];
    NSString *source = [[appleURL componentsSeparatedByString:@"&***source"] lastObject];

    GIF *gif = [[GIF alloc] initWithDownloadURL:download thumbnail:thumbnail andSource:source];
    gif.dateAdded = [NSDate date];

    if([_starred containsObject:gif]){
        NSMutableSet *mutableSet = [NSMutableSet setWithSet:_starred];
        [mutableSet removeObject:gif];
        _starred = mutableSet;
    } else {
        _starred = [_starred setByAddingObject:gif];
    }

    [self saveStarred];
    [_starredController reloadData];
    [_menuController.menuTableView reloadData];
    [_imageBrowser reloadData];
}


- (void)myTableClipBoundsChanged:(NSNotification *)notification
{
    NSClipView *clipView = [notification object];
    NSRect newClipBounds = [clipView bounds];
    CGFloat height = _imageScrollView.contentSize.height;

    if (CGRectGetMinY(newClipBounds) + CGRectGetHeight(newClipBounds) < height + 20) {
        [self getNextGIFs];
    }
}

- (void)gotNewGIFs
{
    [_imageBrowser reloadData];
    NSClipView *clipView = (NSClipView *)[_imageBrowser superview];
    if (CGRectGetHeight(clipView.documentVisibleRect) == CGRectGetHeight([clipView.documentView bounds])) {
        [self getNextGIFs];
    }
}

- (void)getNextGIFs
{
    [_currentSource getNextGIFs:^(NSArray *newGIFs, NSError *error) {
        [_imageBrowser reloadData];
    }];
}

- (NSUInteger) numberOfItemsInImageBrowser:(IKImageBrowserView *) aBrowser
{
    return _currentSource.numberOfGifs;
}

- (void)imageBrowser:(IKImageBrowserView *)aBrowser cellWasRightClickedAtIndex:(NSUInteger)index withEvent:(NSEvent *)event {
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"menu"];
    [menu setAutoenablesItems:NO];

    NSMenuItem *item = [menu addItemWithTitle:@"Copy URL to Clipboard" action: @selector(copyURL) keyEquivalent:@""];
    [item setTarget:self];
    
    item = [menu addItemWithTitle:@"Copy Markdown" action: @selector(copyMarkdown) keyEquivalent:@""];
    [item setTarget:self];

    item = [menu addItemWithTitle:@"Open GIF in Browser" action:@selector(openInBrowser) keyEquivalent:@""];
    item.target = self;

    if (_currentGIF.sourceURL) {
        item = [menu addItemWithTitle:@"Open GIF context" action:@selector(openContext) keyEquivalent:@""];
        item.target = self;
    }

    item = [menu addItemWithTitle:@"Download GIF" action:@selector(downloadGIF) keyEquivalent:@""];
    item.target = self;

    [NSMenu popUpContextMenu:menu withEvent:event forView:aBrowser];
}

- (void)downloadGIF {
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    savePanel.allowedFileTypes = @[@"gif"];
    savePanel.canCreateDirectories = YES;
    savePanel.allowsOtherFileTypes = NO;
    savePanel.canSelectHiddenExtension = YES;

    NSString *downloadDirectoryPath = [
        NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES) firstObject];
    NSURL *downloadDirectoryURL = [NSURL fileURLWithPath:downloadDirectoryPath];
    savePanel.directoryURL = self.userSelectedDirectory ? self.userSelectedDirectory : downloadDirectoryURL;
    savePanel.nameFieldStringValue = _currentGIF.downloadURL.lastPathComponent;

    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:_currentGIF.downloadURL];
    AFHTTPRequestOperation *afhttpRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [afhttpRequestOperation
        setDownloadProgressBlock:^(NSUInteger bytesRead, long long int totalBytesRead, long long int totalBytesExpectedToRead) {
            [self.downloadProgressIndicator setIndeterminate:NO];
            double doubleValue = (double) totalBytesRead / totalBytesExpectedToRead * 100.0;
            [self.downloadProgressIndicator setDoubleValue:doubleValue];
        }];

    [savePanel beginWithCompletionHandler:^(NSInteger result) {
        if (result) {
            self.userSelectedDirectory = savePanel.directoryURL;
            [self.downloadProgressIndicator setHidden:NO];

            [afhttpRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSData * responseObject) {
                BOOL success = [responseObject writeToURL:savePanel.URL atomically:YES];
                if (!success) {
                    NSLog(@"Failed to write file");
                }
                [self.downloadProgressIndicator stopAnimation:nil];
                [self.downloadProgressIndicator setHidden:YES];

            } failure:^(AFHTTPRequestOperation *operation, NSError *error)
            {
                NSLog(@"Fetch failed\n %@ \n %@", operation, error);
            }];

            [self.downloadProgressIndicator startAnimation:nil];
            [afhttpRequestOperation start];
        }
    }];
}

- (void)copyURL {
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] writeObjects:@[_currentGIF.downloadURL]];
}

- (void)copyMarkdown {
    [[NSPasteboard generalPasteboard] clearContents];
    NSString *markdown = [NSString stringWithFormat:@"![gif](%@)", _currentGIF.downloadURL];
    [[NSPasteboard generalPasteboard] writeObjects:@[markdown]];
}

- (void)openInBrowser {
    [[NSWorkspace sharedWorkspace] openURL:_currentGIF.downloadURL];
}

- (void)openContext {
    [[NSWorkspace sharedWorkspace] openURL:_currentGIF.sourceURL];
}

- (id) imageBrowser:(IKImageBrowserView *)aBrowser itemAtIndex:(NSUInteger)index {
    return [_currentSource gifAtIndex:index];;
}

- (void) imageBrowserSelectionDidChange:(IKImageBrowserView *) aBrowser {
    NSInteger index = [[aBrowser selectionIndexes] lastIndex];


    if (index != NSNotFound) {
        GIF *gif = [_currentSource gifAtIndex:index];
        _currentGIF = gif;

        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"gif_template" ofType:@"html"];
        NSString *html = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:nil];
        NSString *address = gif.downloadURL.absoluteString;
        html = [html stringByReplacingOccurrencesOfString:@"{{OR_IMAGE_URL}}" withString:address];
        html = [html stringByReplacingOccurrencesOfString:@"{{OR_THUMB_URL}}" withString:[gif.imageRepresentation absoluteString]];

        if ([_starredController hasGIFWithDownloadAddress:address]) {
            html = [html stringByReplacingOccurrencesOfString:@" id='star' " withString:@" id='star' class='active' "];
        }

        if (html) {
            [[_webView mainFrame] loadHTMLString:html baseURL:nil];
        }
    }
}

- (NSString *)gifFilePath {
    return _gifPath;
}

- (IBAction)togglePopover:(NSButton *)sender
{
    if (!self.createSourcePopover.isShown) {
        [self.createSourcePopover showRelativeToRect:[sender bounds]
                                          ofView:sender
                                   preferredEdge:NSMinYEdge];
    } else {
        [self.createSourcePopover close];
    }
}

- (void)getGIFsFromStarred
{
    
}

@end
