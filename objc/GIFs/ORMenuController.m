//
//  ORMenuController.m
//  GIFs
//
//  Created by orta therox on 12/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "ORMenuController.h"
#import <StandardPaths/StandardPaths.h>

NS_ENUM(NSUInteger, ORMenuTitle){
    ORMenuTitleSearch,
    ORMenuTitleReddit,
    ORMenuTitleTumblr,
    ORMenuTitleStar 
};

@interface ORMenuItem : NSObject <NSCoding>
+ (id)itemWithName:(NSString *)name address:(NSString *)address;

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *address;
@end

@implementation ORMenuItem

+ (id)itemWithName:(NSString *)name address:(NSString *)address {
    ORMenuItem *item = [[ORMenuItem alloc] init];
    item.name = name;
    item.address = address;
    return item;
}

#define kNameKey       @"name"
#define kAddressKey      @"address"

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_name forKey:kNameKey];
    [encoder encodeObject:_address forKey:kAddressKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSString *name = [decoder decodeObjectForKey:kNameKey];
    NSString *address = [decoder decodeObjectForKey:kAddressKey];
    return [self.class itemWithName:name address:address];
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

    [self loadReddit];
    [self loadTumblr];

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
            [_gifViewController getGIFsFromSourceString:@"STARRED"];
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
            [_redditSources removeObjectAtIndex:index];
            [self saveReddit];
            break;

        case ORMenuTitleTumblr:
            [_tumblrSources removeObjectAtIndex:index];
            [self saveTumblr];
            break;

        case ORMenuTitleStar:
            NSLog(@"nada");
    }

    [sourceList reloadData];
}

#pragma mark defaults

- (NSArray *)defaultRedditSources {
    return @[
        [ORMenuItem itemWithName:@"/r/ReactionGIFs" address:@"http://www.reddit.com/r/reactiongifs.json"],
        [ORMenuItem itemWithName:@"/r/GIFs" address:@"http://www.reddit.com/r/gifs.json"],
        [ORMenuItem itemWithName:@"/r/GIF" address:@"http://www.reddit.com/r/gif.json"],
        [ORMenuItem itemWithName:@"/r/aww" address:@"http://www.reddit.com/r/aww.json"],
        [ORMenuItem itemWithName:@"/r/Cinemagraphs" address:@"http://www.reddit.com/r/cinemagraphs.json"],
        [ORMenuItem itemWithName:@"/r/chemicalreactiongifs" address:@"http://www.reddit.com/r/chemicalreactiongifs.json"],
        [ORMenuItem itemWithName:@"/r/perfectloops" address:@"http://www.reddit.com/r/perfectloops.json"],
    ];
}

- (NSArray *)defaultTumblrSources {
    return @[
        [ORMenuItem itemWithName:@"whatshouldwecallme" address:@"http://whatshouldwecallme.tumblr.com"],
        [ORMenuItem itemWithName:@"justinmezzell" address:@"http://justinmezzell.tumblr.com"],
        [ORMenuItem itemWithName:@"beerlabelsinmotion" address:@"http://beerlabelsinmotion.tumblr.com"]
    ];
}

- (void)loadTumblr {
    NSString *path = [[NSFileManager defaultManager] pathForPrivateFile:@"tumblr.data"];
    NSArray *data = [NSKeyedUnarchiver unarchiveObjectWithFile:path];

    if (!data) data = [self defaultTumblrSources];
    _tumblrSources = [data mutableCopy];
}

- (void)saveTumblr {
    NSString *path = [[NSFileManager defaultManager] pathForPrivateFile:@"tumblr.data"];
    [NSKeyedArchiver archiveRootObject:_tumblrSources toFile:path];
}

- (void)addNewTumblr:(NSString *)tumblr {
    NSString *name = [tumblr stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    name = [name stringByReplacingOccurrencesOfString:@".tumblr.com" withString:@""];

    ORMenuItem *item =[ORMenuItem itemWithName:name address:tumblr];
    [_tumblrSources addObject:item];
    [self.menuTableView reloadData];
    [self saveTumblr];
}


- (void)loadReddit {
    NSString *path = [[NSFileManager defaultManager] pathForPrivateFile:@"reddit.data"];
    NSArray *data = [NSKeyedUnarchiver unarchiveObjectWithFile:path];

    if (!data) data = [self defaultRedditSources];
    _redditSources = [data mutableCopy];
}

- (void)saveReddit {
    NSString *path = [[NSFileManager defaultManager] pathForPrivateFile:@"reddit.data"];
    [NSKeyedArchiver archiveRootObject:_redditSources toFile:path];
}

- (void)addNewSubreddit:(NSString *)subreddit {
    NSString *address = [NSString stringWithFormat:@"http://www.reddit.com%@.json", subreddit];

    ORMenuItem *item =[ORMenuItem itemWithName:subreddit address:address];
    [_redditSources addObject:item];
    [self.menuTableView reloadData];
    [self saveTumblr];
}

@end
