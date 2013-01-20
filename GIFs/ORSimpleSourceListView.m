//
//  ORSimpleSourceListView.m
//  GIFs
//
//  Created by orta therox on 20/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "ORSimpleSourceListView.h"

@implementation NSIndexPath(SourceListExtension)
+ (NSIndexPath *)indexPathForRow:(NSInteger)row inSection:(NSInteger)section {
    NSUInteger indexArr[] = { row, section };
    return [NSIndexPath indexPathWithIndexes:indexArr length:2];
}
- (NSUInteger)row { return [self indexAtPosition:0]; }
- (NSUInteger)section { return [self indexAtPosition:1]; }
@end

@implementation ORSourceListItem

@end

@implementation ORSimpleSourceListView {
    // Items stores both titles and items
    NSArray *_items;
    NSUInteger _currentSelectionIndex;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self __setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self __setup];
    }
    return self;
}

- (void)__setup {
    self.delegate = self;
    self.dataSource = self;
    self.focusRingType = NSFocusRingTypeNone;
    self.headerView = nil;
    self.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
    self.intercellSpacing = CGSizeMake(0, 0);
    self.backgroundColor = [NSColor colorWithCalibratedRed:0.2039 green:0.1922 blue:0.2275 alpha:1.0000];

    _currentSelectionIndex = NSNotFound;
}

- (void)awakeFromNib {
    [self reloadData];
}

- (void)reloadData {    
    if(_sourceListDataSource){
        NSUInteger numberOfSections = [_sourceListDataSource numberOfSectionsInSourceList:self];
        if(!numberOfSections) return;

        NSMutableArray *mutableItems = [NSMutableArray array];
        for (int i = 0; i < numberOfSections; i++) {
            [mutableItems addObject:[_sourceListDataSource sourceList:self titleOfHeaderForSection:i]];
            NSUInteger numberOfRows = [_sourceListDataSource sourceList:self numberOfRowsInSection:i];

            for (int j = 0; j < numberOfRows; j++) {
                NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:j inSection:i];
                [mutableItems addObject:[_sourceListDataSource sourceList:self sourceListItemForIndexPath:currentIndexPath]];
            }
        }
        _items = [NSArray arrayWithArray:mutableItems];
    }
    
    [super reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _items.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 24;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {    
    id item =_items[row];
    NSTableCellView *result;
    if ([item isMemberOfClass:[ORSourceListItem class]]){
        ORSourceListItem *sourceListItem = (ORSourceListItem *)item;
        result = [[ORSourceListItemView alloc] initWithSourceListItem:sourceListItem];
        result.textField.stringValue = @"item";

    } else {
        NSString *headerString = (NSString *)item;
        result = [[ORSourceListHeaderView alloc] initWithTitle:headerString];
        result.textField.stringValue = @"HEADER";
    }
    return result;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    id item =_items[row];
    return [item isKindOfClass:[ORSourceListItem class]];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSLog(@"changed selection");
    NSTableView *tableView = notification.object;
    NSInteger index = [self selectedRow];
    if (index == _currentSelectionIndex || index == -1) {
        return;
    }

    id item = _items[index];
    if ([item isMemberOfClass:[ORSourceListItem class]]) {
        if (_currentSelectionIndex != NSNotFound) {
            ORSourceListItemView *oldCell = [self viewAtColumn:0 row:_currentSelectionIndex makeIfNecessary:NO];
            if (oldCell && [oldCell isKindOfClass:[ORSourceListItemView class]]) {
                oldCell.selected = NO;
            }
        }

        ORSourceListItemView *cell = [self viewAtColumn:0 row:index makeIfNecessary:NO];
        if (cell) {
            cell.selected = YES;
        }

        _currentSelectionIndex = index;
        NSIndexPath *path = [self rowToIndexPath:index];
        [_sourceListDelegate sourceList:self selectionDidChangeToIndexPath:path];
    }
}

- (NSIndexPath *)rowToIndexPath:(NSUInteger)row {
    NSInteger indexRow = -1;
    NSInteger indexSection = -1;
    for (int i = 0; i < (row + 1); i++) {
        if ([_items[i] isKindOfClass:[ORSourceListItem class]]) {
            indexRow++;
        } else {
            indexSection++;
            indexRow = -1;
        }
    }
    return [NSIndexPath indexPathForRow:indexRow inSection:indexSection];
}

@end

@implementation ORSourceListHeaderView

- (id)initWithTitle:(NSString *)title {
    self = [super init];
    if(!self)return nil;

    self.textField.stringValue = [title uppercaseString];
    self.textField.textColor = [NSColor colorWithCalibratedRed:0.310 green:0.294 blue:0.341 alpha:1.000];
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    // The lighter grey
    [[NSColor colorWithCalibratedRed:0.2314 green:0.2196 blue:0.2549 alpha:1.0000] set];
	NSRectFill(dirtyRect);
}

@end

@implementation ORSourceListItemView

- (id)initWithSourceListItem:(ORSourceListItem *)item {
    self = [super init];
    if(!self)return nil;

    self.textField.stringValue = item.title;
    self.textField.textColor = [NSColor colorWithCalibratedRed:0.310 green:0.294 blue:0.341 alpha:1.000];
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    if (_selected) {
        [[NSColor colorWithCalibratedRed:0.206 green:0.449 blue:0.940 alpha:1.000] set];
    } else {
        [[NSColor colorWithCalibratedRed:0.150 green:0.140 blue:0.169 alpha:1.000] set];
    }
    NSRectFill(dirtyRect);
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    if (selected) {
        self.textField.textColor = [NSColor colorWithCalibratedRed:0.723 green:0.810 blue:0.955 alpha:1.000];
    } else {
        self.textField.textColor = [NSColor colorWithCalibratedRed:0.2314 green:0.2196 blue:0.2549 alpha:1.0000];
    }
    [self setNeedsDisplay:YES];
}

@end