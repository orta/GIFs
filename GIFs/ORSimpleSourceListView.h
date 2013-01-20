//
//  ORSimpleSourceListView.h
//  GIFs
//
//  Created by orta therox on 20/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ORSimpleSourceListView, ORSourceListItem;

@interface NSIndexPath(SourceListExtension)
+ (NSIndexPath *)indexPathForRow:(NSInteger)row inSection:(NSInteger)section;
- (NSUInteger)row;
- (NSUInteger)section;
@end

@interface ORSourceListHeaderView : NSTableCellView
- (id)initWithTitle:(NSString *)title;
@end
@interface ORSourceListItemView : NSTableCellView
- (id)initWithSourceListItem:(ORSourceListItem *)item;
@property (assign, nonatomic) BOOL selected;
@end

@interface ORSourceListItem : NSObject
@property (strong) NSString *selectedThumbnail;
@property (strong) NSString *thumbnail;
@property (strong) NSString *title;
@end

@protocol ORSourceListDataSource
@required
- (NSUInteger)numberOfSectionsInSourceList:(ORSimpleSourceListView *)sourceList;
- (NSUInteger)sourceList:(ORSimpleSourceListView *)sourceList numberOfRowsInSection:(NSUInteger)section;

- (NSString *)sourceList:(ORSimpleSourceListView *)sourceList titleOfHeaderForSection:(NSUInteger)section;
- (ORSourceListItem *)sourceList:(ORSimpleSourceListView *)sourceList sourceListItemForIndexPath:(NSIndexPath *)indexPath;
@end

@protocol ORSourceListDelegate
- (void)sourceList:(ORSimpleSourceListView *)sourceList selectionDidChangeToIndexPath:(NSIndexPath *)indexPath;
@end


@interface ORSimpleSourceListView : NSTableView <NSTableViewDataSource, NSTableViewDelegate>
@property (weak) IBOutlet id <ORSourceListDelegate> sourceListDelegate;
@property (weak) IBOutlet id <ORSourceListDataSource> sourceListDataSource;
@end
