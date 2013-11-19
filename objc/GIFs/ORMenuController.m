//
//  ORMenuController.m
//  GIFs
//
//  Created by orta therox on 12/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "ORMenuController.h"

NS_ENUM(NSUInteger, ORMenuTitle){
    ORMenuTitleSearch,
    ORMenuTitleReddit,
    ORMenuTitleTumblr,
    ORMenuTitleStar 
};

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
    NSMutableArray *_redditSources;
    NSMutableArray *_tumblrSources;

    NSMutableArray *_searches;
}

- (id) init {
    self = [super init];
    if (!self) return nil;

    _searches = [@[] mutableCopy];

    _redditSources = [@[
        [ORMenuItem itemWithName:@"/r/ReactionGIFs" address:@"http://www.reddit.com/r/reactiongifs.json"],
        [ORMenuItem itemWithName:@"/r/GIFs" address:@"http://www.reddit.com/r/gifs.json"],
        [ORMenuItem itemWithName:@"/r/GIF" address:@"http://www.reddit.com/r/gif.json"],
        [ORMenuItem itemWithName:@"/r/aww" address:@"http://www.reddit.com/r/aww.json"],
        [ORMenuItem itemWithName:@"/r/Cinemagraphs" address:@"http://www.reddit.com/r/cinemagraphs.json"],
        [ORMenuItem itemWithName:@"/r/chemicalreactiongifs" address:@"http://www.reddit.com/r/chemicalreactiongifs.json"],
        [ORMenuItem itemWithName:@"/r/perfectloops" address:@"http://www.reddit.com/r/perfectloops.json"],
    ] mutableCopy];

    _tumblrSources = [@[
        [ORMenuItem itemWithName:@"whatshouldwecallme" address:@"http://whatshouldwecallme.tumblr.com"],
        [ORMenuItem itemWithName:@"justinmezzell" address:@"http://justinmezzell.tumblr.com"],
        [ORMenuItem itemWithName:@"beerlabelsinmotion" address:@"http://beerlabelsinmotion.tumblr.com"]
    ] mutableCopy];

    return self;
}

- (void)awakeFromNib {
    _window.titleBarHeight = 40;
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
    switch (section) {
        case ORMenuTitleSearch:
            return @"Search";

        case ORMenuTitleReddit:
            return @"Reddit";

        case ORMenuTitleTumblr:
            return @"Tumblr";

        case ORMenuTitleStar:
            return @"Starred";
    }

    return @"";
}

- (ORSourceListItem *)sourceList:(ORSimpleSourceListView *)sourceList sourceListItemForIndexPath:(NSIndexPath *)indexPath {
    ORSourceListItem *item = [[ORSourceListItem alloc] init];
    ORMenuItem *menuItem = nil;
    item.rightButtonImage = @"close";
    item.rightButtonActiveImage = @"close_active";

    switch (indexPath.section) {
        case ORMenuTitleSearch:
            item.title = _searches[indexPath.row];
            item.thumbnail = @"Search";
            item.selectedThumbnail = @"SearchWhite";
            return item;

        case ORMenuTitleReddit:
            menuItem = _redditSources[indexPath.row];
            item.title = [menuItem name];
            item.thumbnail = @"Reddit";
            item.selectedThumbnail = @"RedditWhite";

            return item;

        case ORMenuTitleTumblr:
            menuItem = _tumblrSources[indexPath.row];
            item.title = menuItem.name;
            item.thumbnail = @"tumblr_t";
            item.selectedThumbnail = @"tumblr_t_active";

            return  item;

        case ORMenuTitleStar:
            item.title = @"⭐";
            item.thumbnail = @"";
            item.selectedThumbnail = @"";
            return item;
    }

    return nil;
}

- (NSUInteger)sourceList:(ORSimpleSourceListView *)sourceList numberOfRowsInSection:(NSUInteger)section {
    switch (section) {
        case ORMenuTitleSearch:
            return _searches.count;

        case ORMenuTitleReddit:
            return _redditSources.count;

        case ORMenuTitleTumblr:
            return _tumblrSources.count;

        case ORMenuTitleStar:
            return 1;
    }
    return 0;
}

- (NSUInteger)numberOfSectionsInSourceList:(ORSimpleSourceListView *)sourceList {
    return 4;
}

#pragma mark -
#pragma mark ORSourceListDelegate

- (void)sourceList:(ORSimpleSourceListView *)sourceList selectionDidChangeToIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = indexPath.row;
    ORMenuItem *item = nil;

    switch (indexPath.section) {
        case ORMenuTitleSearch:
            [_gifViewController getGIFsFromSourceString:_searches[index]];
            break;

        case ORMenuTitleReddit:
            item = _redditSources[index];
            [_gifViewController getGIFsFromSourceString:[item address]];
            break;

        case ORMenuTitleTumblr:
            item = _tumblrSources[index];
            [_gifViewController getGIFsFromSourceString:[item address]];
            break;

        case ORMenuTitleStar:
            NSLog(@"nada");
    }
}

- (void)sourceList:(ORSimpleSourceListView *)sourceList didClickOnRightButtonForIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = indexPath.row;

    switch (indexPath.section) {
        case ORMenuTitleSearch:
            [_searches removeObjectAtIndex:index];
            break;

        case ORMenuTitleReddit:
            break;

        case ORMenuTitleTumblr:
            break;

        case ORMenuTitleStar:
            NSLog(@"nada");
    }

    [sourceList reloadData];
}

@end
