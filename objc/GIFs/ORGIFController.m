//
//  ORGIFController.m
//  GIFs
//
//  Created by orta therox on 13/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "ORGIFController.h"
#import <GIFKit/ORRedditSearchNetworkModel.h>
#import <GIFKit/ORGiphyNetworkModel.h>
#import <GIFKit/ORSubredditNetworkModel.h>
#import "ORTumblrController.h"
#import "ORStarredSourceController.h"
#import <StandardPaths/StandardPaths.h>
#import "NSString+StringBetweenStrings.h"
#import "ORMenuController.h"
#import "GIFs-Swift.h"
#import "ORGIFRightClickMenuMaker.h"
#import <Keys/GIFsKeys.h>

@interface GIF()
@property (nonatomic, strong, readwrite) NSDate *dateAdded;
@end

@interface ORGIFController ()
@property(nonatomic, strong) IBOutlet ORWindowTitleDecorationController *windowDecorationController;

@property(nonatomic, copy) NSURL *lastUserSelectedDirectory;
@property(nonatomic, copy) ORGIFRightClickMenuMaker *menuMaker;
@end

@implementation ORGIFController {
    NSObject <ORGIFSource> *_currentSource;
    NSSet *_starred;
    NSString *_gifPath;

    CALayer *_headerLayer;
}

- (void)getGIFsFromSourceString:(NSString *)string {
    BOOL showGiphyLogo = NO;
    
    if([string rangeOfString:@"/r/"].location != NSNotFound) {
        _currentSource = _redditController;
        [_redditController setSubreddit:string];
    }

    else if([string rangeOfString:@".tumblr"].location != NSNotFound) {
        _currentSource = _tumblrController;
        [_tumblrController setTumblrURL:string];

    } else if([string isEqualToString:@"STARRED"]){
        _currentSource = _starredController;
        _starredController.gifController = self;
        [_starredController reloadData];

    } else {
        _currentSource = _searchController;
        [_searchController setQuery:string];
        [_searchController setAPIKey:[GifsKeys new].giphyAPIKey];
        showGiphyLogo = YES;
    }
    
    [self.windowDecorationController showGiphyLogo:showGiphyLogo];
    [self getNextGIFs];
    [self.collectionView reloadData];
    self.sectionTitle.stringValue = string;
}

- (void)awakeFromNib {
    self.webView.drawsBackground = NO;
    self.webView.frame = self.webView.superview.bounds;

    [self.collectionView.superview setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myTableClipBoundsChanged:)
                                                 name:NSViewBoundsDidChangeNotification object:self.collectionView.superview];

    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];

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
    NSString *thumbnail = [appleURL substringBetween:@"***thumb=" and:@"&***source_title"];
    NSString *source = [[appleURL componentsSeparatedByString:@"&***source="] lastObject];
    NSString *sourceTitle = [appleURL substringBetween:@"***source_title=" and:@"&***source="];
    sourceTitle = [sourceTitle stringByRemovingPercentEncoding];
	
    GIF *gif = [[GIF alloc] initWithDownloadURL:download thumbnail:thumbnail source:source sourceTitle:sourceTitle];
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
    [_menuController reloadFavourites];
    
}

- (void)myTableClipBoundsChanged:(NSNotification *)notification
{
    NSClipView *clipView = [notification object];
    NSRect newClipBounds = [clipView bounds];
    CGFloat height = [(NSScrollView *)_collectionView.superview.superview contentSize].height;
    
    if (CGRectGetMinY(newClipBounds) + CGRectGetHeight(newClipBounds) < height + 20) {
        [self getNextGIFs];
    }

}

- (void)gotNewGIFs
{
    NSClipView *clipView = (NSClipView *)[self.collectionView superview];
    
    CGFloat clipViewVisibleHeight = CGRectGetHeight(clipView.documentVisibleRect);
    CGFloat clipViewDocumentHeight = CGRectGetHeight([clipView.documentView bounds]);
    if (clipViewVisibleHeight == clipViewDocumentHeight) {
        [self getNextGIFs];
    }

}

- (void)getNextGIFs
{
    [_currentSource getNextGIFs:^(NSArray *newGIFs, NSError *error) {
        [self.collectionView reloadData];
        [self gotNewGIFs];

        if (!self.currentGIF){
            NSIndexSet *set = [NSIndexSet indexSetWithIndex:0];
            [self.collectionView setSelectionIndexes:set byExtendingSelection:YES];
        }
    }];
}

-(NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView *)aBrowser
{
    return _currentSource.numberOfGifs;
}

-(id)imageBrowser:(IKImageBrowserView *)aBrowser itemAtIndex:(NSUInteger)index
{
    return [_currentSource gifAtIndex:index];
}

-(void)imageBrowser:(IKImageBrowserView *)aBrowser cellWasRightClickedAtIndex:(NSUInteger)index withEvent:(NSEvent *)event
{
    _menuMaker = [[ORGIFRightClickMenuMaker alloc] initWithGIF:self.currentGIF];
    [NSMenu popUpContextMenu:self.menuMaker.menu withEvent:event forView:aBrowser];
}

- (void) imageBrowserSelectionDidChange:(IKImageBrowserView *) aBrowser;
{
    NSInteger index = aBrowser.selectionIndexes.firstIndex;

    if (index != NSNotFound) {
        GIF *gif = [_currentSource gifAtIndex:index];
        _currentGIF = gif;

        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"gif_template" ofType:@"html"];
        NSString *html = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:nil];
        NSString *address = gif.downloadURL.absoluteString ?: @"";
        html = [html stringByReplacingOccurrencesOfString:@"{{OR_IMAGE_URL}}" withString:address];
        html = [html stringByReplacingOccurrencesOfString:@"{{OR_THUMB_URL}}" withString:[gif.imageRepresentation absoluteString] ?: @""];
        html = [html stringByReplacingOccurrencesOfString:@"{{OR_SOURCE_URL}}" withString:[gif.sourceURL absoluteString] ?: @""];
		html = [html stringByReplacingOccurrencesOfString:@"{{OR_SOURCE_TITLE}}" withString:gif.sourceTitle ?: @""];

        self.gifTitle.stringValue = gif.sourceTitle;
        
        if ([_starredController hasGIFWithDownloadAddress:address]) {
            html = [html stringByReplacingOccurrencesOfString:@" id='star' " withString:@" id='star' class='active' "];
        }

        if (html) {
            NSString *title = [@" " stringByAppendingString:gif.sourceTitle];
            [self.openGIFContextButton setTitle:title];
            [[_webView mainFrame] loadHTMLString:html baseURL:nil];
        }
    }
}
//
//    - (NSUInteger) numberOfGroupsInImageBrowser:(IKImageBrowserView *) aBrowser
//    {
//        return 1;
//    }
//
//    - (NSDictionary *) imageBrowser:(IKImageBrowserView *)aBrowser groupAtIndex:(NSUInteger)index
//    {
//        CALayer *headerLayer = [CALayer layer];
//        headerLayer.bounds = CGRectMake(0.0, 0.0, 1.0, 70.0);
//        headerLayer.backgroundColor = [NSColor whiteColor].CGColor;
//
//        NSValue *range = [NSValue valueWithRange:NSMakeRange(0, [self numberOfItemsInImageBrowser:aBrowser])];
//
//        return @{
//             IKImageBrowserGroupStyleKey: @(IKGroupDisclosureStyle),
//             IKImageBrowserGroupHeaderLayer: headerLayer,
//             IKImageBrowserGroupRangeKey: range
//         };
//    }

- (NSString *)gifFilePath {
    return _gifPath;
}

- (IBAction)openCurrentGIF:(NSButton *)sender
{
    [[NSWorkspace sharedWorkspace] openURL:self.currentGIF.sourceURL];
}

- (IBAction)togglePopover:(NSButton *)sender
{
    if (!self.createSourcePopover.isShown) {
        self.createSourcePopover.behavior = NSPopoverBehaviorTransient;
        [self.createSourcePopover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMinYEdge];
        
    } else {
        [self.createSourcePopover close];
    }
}

#pragma mark - ORImageBrowserViewDelegate

- (NSURL *)URLForCurrentGIF
{
    return [self.currentGIF downloadURL];
}

- (NSURL *)URLForCurrentGIFContext
{
    return [self.currentGIF sourceURL];
}

- (NSString *)sourceTitleForCurrentGIF
{
    return self.currentGIF.sourceTitle;
}

@end
