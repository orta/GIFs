//
//  ORMenuController.m
//  GIFs
//
//  Created by orta therox on 12/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "ORMenuController.h"

@implementation ORMenuController {
    NSMutableDictionary *_sources;
    NSMutableArray *_searches;
}

- (id) init {
    self = [super init];
    if (!self) return nil;

    _searches = [@[] mutableCopy];
    _sources = [@{
                    @"/r/GIFs": @"http://www.reddit.com/r/gifs.json",
                    @"/r/GIF": @"http://www.reddit.com/r/gif.json",
                    @"/r/WhitePeopleGIFs": @"http://www.reddit.com/r/whitepeoplegifs.json",
                    @"/r/BlackPeopleGIFs": @"http://www.reddit.com/r/blackpeoplegifs.json",
                    @"/r/ReactionGIFs": @"http://www.reddit.com/r/reactiongifs.json"
    } mutableCopy];

    return self;
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
        item.title = _sources.allKeys[indexPath.row];
        item.thumbnail = @"Reddit";
        item.selectedThumbnail = @"RedditWhite";
        return item;
    } else {
        ORSourceListItem *item = [[ORSourceListItem alloc] init];
        item.title = _searches[indexPath.row];
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
        [_gifViewController getGIFsFromSourceString:_sources.allValues[index]];
    } else {
        [_gifViewController getGIFsFromSourceString:_searches[index]];
    }
}


@end
