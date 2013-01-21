//
//  ORMenuController.m
//  GIFs
//
//  Created by orta therox on 12/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "ORMenuController.h"

@interface ORMenuItem : NSObject
+ (id)itemWithName:(NSString *)name address:(NSString *)address;
@property NSString *name;
@property NSString *address;
@end

@implementation ORMenuItem
+ (id)itemWithName:(NSString *)name address:(NSString *)address {
    ORMenuItem *item = [[ORMenuItem alloc] init];
    item.name = name;
    item.address = address;
    return item;
}
@end

@implementation ORMenuController {
    NSMutableArray *_sources;    
    NSMutableArray *_searches;
}

- (id) init {
    self = [super init];
    if (!self) return nil;

    _searches = [@[] mutableCopy];

    _sources = [@[
        [ORMenuItem itemWithName:@"/r/ReactionGIFs" address:@"http://www.reddit.com/r/reactiongifs.json"],
        [ORMenuItem itemWithName:@"/r/GIFs" address:@"http://www.reddit.com/r/gifs.json"],
        [ORMenuItem itemWithName:@"/r/GIF" address:@"http://www.reddit.com/r/gif.json"],
        [ORMenuItem itemWithName:@"/r/aww" address:@"http://www.reddit.com/r/aww.json"],
        [ORMenuItem itemWithName:@"/r/WhitePeopleGIFs" address:@"http://www.reddit.com/r/whitepeoplegifs.json"],
        [ORMenuItem itemWithName:@"/r/BlackPeopleGIFs" address:@"http://www.reddit.com/r/blackpeoplegifs.json"],
        [ORMenuItem itemWithName:@"/r/AsianPeopleGIFs" address:@"http://www.reddit.com/r/asianpeoplegifs.json"]
    ] mutableCopy];

    return self;
}

- (void)awakeFromNib {
    _window.titleBarHeight = 60;
    _windowToolbar.frame = self.window.titleBarView.bounds;
    _windowToolbar.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [_window.titleBarView addSubview:_windowToolbar];
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    NSSearchField *searchField = (NSSearchField *)control;
    [_searches insertObject:searchField.stringValue atIndex:0];
    [searchField setStringValue:@""];

    [_menuTableView reloadData];
    
    [_menuTableView setSelectedIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

    return YES;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if(dividerIndex == 0){
        return 180;
    }
    return proposedMinimumPosition;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if(dividerIndex == 0){
        return 240;
    }
    return proposedMaximumPosition;
}

#pragma mark -
#pragma mark ORSourceListDataSource

- (NSString *)sourceList:(ORSimpleSourceListView *)sourceList titleOfHeaderForSection:(NSUInteger)section {
    if (section) {
        return @"REDDIT";
    }
    return @"SEARCH";
}

- (ORSourceListItem *)sourceList:(ORSimpleSourceListView *)sourceList sourceListItemForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section) {
        ORSourceListItem *item = [[ORSourceListItem alloc] init];
        ORMenuItem *menuItem = _sources[indexPath.row];
        item.title = menuItem.name;
        item.thumbnail = @"Reddit";
        item.selectedThumbnail = @"RedditWhite";
        return item;
    } else {
        ORSourceListItem *item = [[ORSourceListItem alloc] init];
        item.title = _searches[indexPath.row];
        item.thumbnail = @"Search";
        item.selectedThumbnail = @"SearchWhite";

        return item;
    }
}

- (NSUInteger)sourceList:(ORSimpleSourceListView *)sourceList numberOfRowsInSection:(NSUInteger)section {
    if (section) {
        return _sources.count;
    } else {
        return _searches.count;
    }
}

- (NSUInteger)numberOfSectionsInSourceList:(ORSimpleSourceListView *)sourceList {
    return 2;
}

#pragma mark -
#pragma mark ORSourceListDelegate

- (void)sourceList:(ORSimpleSourceListView *)sourceList selectionDidChangeToIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = indexPath.row;
    
    if(indexPath.section){
        [_gifViewController getGIFsFromSourceString:[_sources[index] address]];
    } else {
        [_gifViewController getGIFsFromSourceString:_searches[index]];
    }
}


@end
