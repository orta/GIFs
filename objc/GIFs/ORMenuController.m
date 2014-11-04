//
//  ORMenuController.m
//  GIFs
//
//  Created by orta therox on 12/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "ORMenuController.h"
#import <StandardPaths/StandardPaths.h>
#import "ORStarredSourceController.h"

NS_ENUM(NSUInteger, ORMenuTitle){
    ORMenuTitleStar,
    ORMenuTitleSearch,
    ORMenuTitleReddit,
    ORMenuTitleTumblr
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
    NSTextField *searchField = (NSTextField *)control;
    [_searches insertObject:searchField.stringValue atIndex:0];
    [searchField setStringValue:@""];

    [_menuTableView reloadData];
    
    [_menuTableView setSelectedIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    return YES;
}

- (void)reloadFavourites
{

    NSTableRowView *row = [self.menuTableView rowViewAtRow:1 makeIfNecessary:NO];
    NSTableCellView *cell = [row viewAtColumn:0];
    
    CABasicAnimation *anime = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    anime.fromValue = (id)[cell.layer backgroundColor];
    anime.toValue = (id) [NSColor colorWithCalibratedRed:1.000 green:0.965 blue:0.722 alpha:1.000].CGColor;
    anime.duration = 0.15;
    anime.autoreverses = YES;

    [cell.layer addAnimation:anime forKey:@"backgroundColor"];
    cell.textField.stringValue = [self titleForStars];
}

#pragma mark -
#pragma mark ORSourceListDataSource


- (NSImage *)sourceList:(ORSimpleSourceListView *)sourceList imageForHeaderInSection:(NSUInteger)section {
    switch (section) {
        case ORMenuTitleSearch:
            return [NSImage imageNamed:@"SearchWhite"];
            
        case ORMenuTitleReddit:
            return [NSImage imageNamed:@"RedditWhite"];

        case ORMenuTitleTumblr:
            return [NSImage imageNamed:@"tumblr_t_active"];

        case ORMenuTitleStar:
            return [NSImage imageNamed:@"tick"];
    }
    
    return nil;
}

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
            item.title = [self titleForStars];
            return item;
    }

    return nil;
}

- (NSString *)titleForStars
{
    NSInteger count = [self.starredController numberOfGifs];
    switch (count) {
        case 0:
            return @"No ⭐s";
        case 1:
            return @"⭐";
        case 2:
            return @"⭐⭐";
        case 3:
            return @"⭐⭐⭐";
        case 4:
            return @"⭐⭐⭐⭐";
        case 5:
            return @"⭐⭐⭐⭐⭐";
        default:
            return [NSString stringWithFormat:@"%li ⭐s", (long)count];
    }
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
            [_gifViewController getGIFsFromSourceString:item.name];
            break;

        case ORMenuTitleTumblr:
            item = _tumblrSources[index];
            [_gifViewController getGIFsFromSourceString:item.address];
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
            break;
    }

    [sourceList reloadData];
}

#pragma mark defaults

- (NSArray *)defaultRedditSources {
    return @[
        [ORMenuItem itemWithName:@"/r/ReactionGIFs" address:@"reactiongifs"],
        [ORMenuItem itemWithName:@"/r/GIFs" address:@"gifs"],
        [ORMenuItem itemWithName:@"/r/GIF" address:@"gif"],
        [ORMenuItem itemWithName:@"/r/aww_gifs" address:@"aww_gifs"],
        [ORMenuItem itemWithName:@"/r/Cinemagraphs" address:@"cinemagraphs"],
        [ORMenuItem itemWithName:@"/r/chemicalreactiongifs" address:@"chemicalreactiongifs"],
        [ORMenuItem itemWithName:@"/r/perfectloops" address:@"perfectloops"],
        [ORMenuItem itemWithName:@"/r/highqualitygifs" address:@"highqualitygifs"],
    ];
}

- (NSArray *)defaultTumblrSources {
    return @[
        [ORMenuItem itemWithName:@"What Should We Call Me" address:@"http://whatshouldwecallme.tumblr.com"],
        [ORMenuItem itemWithName:@"Animaly GIFs" address:@"http://animalygifs.tumblr.com"],
        [ORMenuItem itemWithName:@"GIF Movie" address:@"http://gifmovie.tumblr.com"],
        [ORMenuItem itemWithName:@"Reality TV GIFs" address:@"http://realitytvgifs.tumblr.com"],
        [ORMenuItem itemWithName:@"Mr GIF" address:@"http://mr-gif.com"],
        [ORMenuItem itemWithName:@"Beer Labels In Motion" address:@"http://beerlabelsinmotion.tumblr.com"],
        [ORMenuItem itemWithName:@"Bees & Bombs" address:@"http://beesandbombs.tumblr.com"]
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
    NSString *address = [subreddit stringByReplacingOccurrencesOfString:@"/r/" withString:@""];
    address = [address stringByReplacingOccurrencesOfString:@"http://reddit.com/" withString:@""];
    address = [address stringByReplacingOccurrencesOfString:@"/" withString:@""];

    ORMenuItem *item =[ORMenuItem itemWithName:subreddit address:address];
    [_redditSources addObject:item];
    [self.menuTableView reloadData];
    [self saveReddit];
}

- (void)makeSearchFieldFirstResponder:(id)sender
{
    [self.searchBar becomeFirstResponder];
}

@end
