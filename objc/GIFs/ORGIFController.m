//
//  ORGIFController.m
//  GIFs
//
//  Created by orta therox on 13/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "ORGIFController.h"
#import "ORRedditImageController.h"
#import "ORSearchController.h"
#import "ORTumblrController.h"
#import "ORStarredSourceController.h"
#import "GIF.h"
#import "AFNetworking.h"
#import <StandardPaths/StandardPaths.h>
#import "NSString+StringBetweenStrings.h"

@implementation ORGIFController {
    NSObject <ORGIFSource> *_currentSource;
    NSSet *_starred;
    NSString *_gifPath;

    AFImageRequestOperation *_gifDownloadOp;
}

- (void)getGIFsFromSourceString:(NSString *)string {
    if([string rangeOfString:@"reddit"].location != NSNotFound){
        _currentSource = _redditController;
        _searchController.gifViewController = self;
        [_redditController setRedditURL:string];
    }

    else if([string rangeOfString:@".tumblr"].location != NSNotFound){
        _currentSource = _tumblrController;
        _searchController.gifViewController = self;
        [_tumblrController setTumblrURL:string];

    } else if([string isEqualToString:@"STARRED"]){
        _currentSource = _starredController;
        _starredController.gifController = self;
        [_starredController reloadData];

    } else {
        _currentSource = _searchController;
        _searchController.gifViewController = self;
        [_searchController setSearchQuery:string];
    }
    
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
    NSString *thumbnail = [[appleURL componentsSeparatedByString:@"***thumb="] lastObject];

    GIF *gif = [[GIF alloc] initWithDownloadURL:download andThumbnail:thumbnail];
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
    [_imageBrowser reloadData];
}


- (void)myTableClipBoundsChanged:(NSNotification *)notification {
    NSClipView *clipView = [notification object];
    NSRect newClipBounds = [clipView bounds];
    CGFloat height = _imageScrollView.contentSize.height;

    if (CGRectGetMinY(newClipBounds) + CGRectGetHeight(newClipBounds) < height + 20) {
        [_currentSource getNextGIFs];
    }
}

- (void)gotNewGIFs {
    [_imageBrowser reloadData];
    NSClipView *clipView = (NSClipView *)[_imageBrowser superview];
    if (CGRectGetHeight(clipView.documentVisibleRect) == CGRectGetHeight([clipView.documentView bounds])) {
        [_currentSource getNextGIFs];
    }
}

- (NSUInteger) numberOfItemsInImageBrowser:(IKImageBrowserView *) aBrowser {
    return _currentSource.numberOfGifs;
}

- (void)imageBrowser:(IKImageBrowserView *)aBrowser cellWasRightClickedAtIndex:(NSUInteger)index withEvent:(NSEvent *)event {
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"menu"];
    [menu setAutoenablesItems:NO];
    NSMenuItem *item = [menu addItemWithTitle:@"Copy URL to Clipboard" action: @selector(copyURL) keyEquivalent:@""];
    [item setTarget:self];
    [NSMenu popUpContextMenu:menu withEvent:event forView:aBrowser];
}

- (void)copyURL {
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] writeObjects:@[_currentGIF.downloadURL]];
}

- (id) imageBrowser:(IKImageBrowserView *)aBrowser itemAtIndex:(NSUInteger)index {
    return [_currentSource gifAtIndex:index];;
}

- (void) imageBrowserSelectionDidChange:(IKImageBrowserView *) aBrowser {
    NSInteger index = [[aBrowser selectionIndexes] lastIndex];


    if (index != NSNotFound) {
        GIF *gif = [_currentSource gifAtIndex:index];
        _currentGIF = gif;
//
//        _imageView.image = nil;
//        NSURLRequest *request = [NSURLRequest requestWithURL:gif.downloadURL];
//        _progressView.hidden = YES;
//        if (_gifDownloadOp) [_gifDownloadOp cancel];
//        
//        _gifDownloadOp = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(NSImage *image) {
//            [_imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO ];
//            _progressView.hidden = YES;
//            _gifPath = [NSTemporaryDirectory() stringByAppendingString:@"gif-app.gif"];
//            [_gifDownloadOp.responseData writeToFile:_gifPath atomically:YES];
//        }];
//
//        __block DDProgressView *progressView = _progressView;
//        [_gifDownloadOp setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//            progressView.progress = totalBytesRead / (CGFloat)totalBytesExpectedToRead;
//        }];
//
//        [_gifDownloadOp start];

        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"gif_template" ofType:@"html"];
        NSString *html = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:nil];
        html = [html stringByReplacingOccurrencesOfString:@"{{OR_IMAGE_URL}}" withString:gif.downloadURL.absoluteString];
        html = [html stringByReplacingOccurrencesOfString:@"{{OR_THUMB_URL}}" withString:[gif.imageRepresentation absoluteString]];

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
