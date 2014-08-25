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
#import <StandardPaths/StandardPaths.h>
#import "NSString+StringBetweenStrings.h"
#import "ORMenuController.h"
#import "GIFs-Swift.h"
#import <JNWScrollView/JNWScrollView.h>
#import "ORGIFRightClickMenuMaker.h"

@interface GIF()
@property (nonatomic, strong, readwrite) NSDate *dateAdded;
@end

@interface ORGIFController () <JNWCollectionViewDataSource, JNWCollectionViewDelegate, JNWCollectionViewGridLayoutDelegate>

@property(nonatomic, copy) NSURL *lastUserSelectedDirectory;
@property(nonatomic, copy) ORGIFRightClickMenuMaker *menuMaker;
@end

@implementation ORGIFController {
    NSObject <ORGIFSource> *_currentSource;
    NSSet *_starred;
    NSString *_gifPath;
}

- (void)getGIFsFromSourceString:(NSString *)string {
    if([string rangeOfString:@"/r/"].location != NSNotFound){
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
    [self.collectionView reloadData];
    self.sectionTitle.stringValue = string;
}

- (void)awakeFromNib {
    self.webView.drawsBackground = NO;
    
    [self.collectionView registerClass:GridViewCell.class forCellWithReuseIdentifier:@"gif"];
    self.collectionView.backgroundColor = [NSColor colorWithCalibratedRed:0.955 green:0.950 blue:0.970 alpha:1.000];
    
    JNWCollectionViewGridLayout *layout = [[JNWCollectionViewGridLayout alloc] init];
    layout.delegate = self;
    layout.itemSize = CGSizeMake(90, 90);
    layout.verticalSpacing = 20;
    layout.itemHorizontalMargin = 20;

    self.collectionView.collectionViewLayout = layout;
    
    [self.collectionView.clipView setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myTableClipBoundsChanged:)
                                                 name:NSViewBoundsDidChangeNotification object:self.collectionView.clipView];

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
    [_menuController.menuTableView reloadData];
    
}


- (void)myTableClipBoundsChanged:(NSNotification *)notification
{
    NSClipView *clipView = [notification object];
    NSRect newClipBounds = [clipView bounds];
    CGFloat height = _collectionView.contentSize.height;

    if (CGRectGetMinY(newClipBounds) + CGRectGetHeight(newClipBounds) < height + 20) {
        [self getNextGIFs];
    }
}

- (void)gotNewGIFs
{
    NSClipView *clipView = (NSClipView *)[_collectionView clipView];
    
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
    }];
}

- (NSEdgeInsets)collectionView:(JNWCollectionView *)collectionView layout:(JNWCollectionViewGridLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat totalWidth = collectionView.visibleSize.width - collectionViewLayout.itemHorizontalMargin;
    NSUInteger numberOfColumns = totalWidth / (collectionViewLayout.itemSize.width + collectionViewLayout.itemHorizontalMargin);
    CGFloat totalOffset = totalWidth - (numberOfColumns * (collectionViewLayout.itemSize.width + collectionViewLayout.itemHorizontalMargin ));
    
    return NSEdgeInsetsMake(0, totalOffset/2, 0, 0);
}

- (CGFloat)collectionView:(JNWCollectionView *)collectionView heightForHeaderInSection:(NSInteger)index
{
    return 60;
}

- (NSUInteger)collectionView:(JNWCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _currentSource.numberOfGifs;
}

- (JNWCollectionViewCell *)collectionView:(JNWCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GridViewCell *cell = (id)[collectionView dequeueReusableCellWithIdentifier:@"gif"];
    if (cell) {
        cell.backgroundColor = [NSColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];

        GIF *gif = [_currentSource gifAtIndex:indexPath.jnw_item];
        [cell updateWithURL:gif.imageRepresentation];
    }
    return cell;
}

- (void)collectionView:(JNWCollectionView *)collectionView didRightClickItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSEvent *event = collectionView.window.currentEvent;

    _menuMaker = [[ORGIFRightClickMenuMaker alloc] initWithGIF:self.currentGIF];
    [NSMenu popUpContextMenu:self.menuMaker.menu withEvent:event forView:collectionView];
}

- (void)collectionView:(JNWCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.jnw_item;

    if (index != NSNotFound) {
        GIF *gif = [_currentSource gifAtIndex:index];
        _currentGIF = gif;

        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"gif_template" ofType:@"html"];
        NSString *html = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:nil];
        NSString *address = gif.downloadURL.absoluteString;
        html = [html stringByReplacingOccurrencesOfString:@"{{OR_IMAGE_URL}}" withString:address];
        html = [html stringByReplacingOccurrencesOfString:@"{{OR_THUMB_URL}}" withString:[gif.imageRepresentation absoluteString]];
		html = [html stringByReplacingOccurrencesOfString:@"{{OR_SOURCE_URL}}" withString:[gif.sourceURL absoluteString]];
		html = [html stringByReplacingOccurrencesOfString:@"{{OR_SOURCE_TITLE}}" withString:gif.sourceTitle];


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

@end
