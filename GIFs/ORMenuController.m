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

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _sources.allKeys.count + _searches.count;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    NSTableCellView *result = [tableView makeViewWithIdentifier:@"menuItem" owner:self];
    if (row < _searches.count) {
        result.textField.stringValue = _searches[row];
    } else {
        result.textField.stringValue = _sources.allKeys[row - _searches.count];
    }
    return result;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView *tableView = notification.object;
    NSInteger index = [tableView selectedRow];
    
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    NSLog(@"%@ - %@", NSStringFromSelector(_cmd), control);
    NSSearchField *searchField = (NSSearchField *)control;
    [_searches insertObject:searchField.stringValue atIndex:0];
    [searchField setStringValue:@""];
    
    [_menuTableView becomeFirstResponder];
    [_menuTableView reloadData];
    [_menuTableView selectRowIndexes:[[NSIndexSet alloc] initWithIndex:0] byExtendingSelection:NO];

    return YES;
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
    NSLog(@"%@ - %@", NSStringFromSelector(_cmd), indexPath);
    
    if (indexPath.section) {
        ORSourceListItem *item = [[ORSourceListItem alloc] init];
        item.title = _sources.allKeys[indexPath.row];
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
