//
//  ORSimpleSourceListView.m
//  GIFs
//
//  Created by orta therox on 20/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "ORSimpleSourceListView.h"

CGFloat ORCellHeight = 36;
CGFloat ORCellLeftPadding = 12;

CGFloat ORCellTitleTopPadding = 8;

CGFloat ORCellItemLeftPadding = 40;
CGFloat ORCellItemTopPadding = 8;

CGFloat ORCellImageDimensions = 16;

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
    self.backgroundColor = [NSColor clearColor];
    self.enclosingScrollView.drawsBackground = NO;
    self.intercellSpacing = CGSizeMake(0, 0);
    self.allowsMultipleSelection = NO;
    self.allowsEmptySelection = NO;
    self.enclosingScrollView.scrollerStyle = NSScrollerStyleOverlay;
    self.selectionColor = [NSColor colorWithWhite:0.3 alpha:1];
    
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
    return ORCellHeight;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {    
    id item =_items[row];
    NSTableCellView *result;
    if ([item isMemberOfClass:[ORSourceListItem class]]){
        ORSourceListItem *sourceListItem = (ORSourceListItem *)item;
        result = [[ORSourceListItemView alloc] initWithSourceListItem:sourceListItem sourceList:self];

        if (row == _currentSelectionIndex) {
            [(ORSourceListItemView *)result setSelected:YES];
        }

    } else {
        NSString *headerString = (NSString *)item;
        result = [[ORSourceListHeaderView alloc] initWithTitle:headerString sourceList:self];
        result.imageView.image = [self.sourceListDataSource sourceList:self imageForHeaderInSection:row];
    }

    return result;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    return [[ORSourceListRowView alloc] init];
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    id item =_items[row];
    return [item isKindOfClass:[ORSourceListItem class]];
}

- (void)selectTopItem
{
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:2];
    [self selectRowIndexes:set byExtendingSelection:NO];
}

- (void)setSelectedIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = [self indexPathToRow:indexPath];
    if (index != NSNotFound) {
        NSIndexSet *set = [[NSIndexSet alloc] initWithIndex:index];
        [self selectRowIndexes:set byExtendingSelection:NO];
    }
}

- (void)selectRowIndexes:(NSIndexSet *)indexes byExtendingSelection:(BOOL)extend {
    NSUInteger newIndex = [indexes firstIndex];
    if (newIndex != NSNotFound) {
        [self _changeSelectionToRow:newIndex];
        [super selectRowIndexes:indexes byExtendingSelection:extend];

        id item = _items[newIndex];
        if ([item isMemberOfClass:[ORSourceListItem class]]) {
            NSIndexPath *path = [self rowToIndexPath:newIndex];
            [_sourceListDelegate sourceList:self selectionDidChangeToIndexPath:path];
        }
    }
}

- (void)_changeSelectionToRow:(NSInteger)row {
    if (_currentSelectionIndex != NSNotFound) {
        [self _visuallySelectRowAtIndex:_currentSelectionIndex toState:NO];
    }
    _currentSelectionIndex = row;
    [self _visuallySelectRowAtIndex:row toState:YES];
}

- (void)_visuallySelectRowAtIndex:(NSUInteger)index toState:(BOOL)state {
    ORSourceListItemView *cell = [self viewAtColumn:0 row:index makeIfNecessary:NO];
    ORSourceListRowView *row = [self rowViewAtRow:index makeIfNecessary:NO];
    
    row.selected = state;
}

- (NSUInteger)indexPathToRow:(NSIndexPath *)path {
    NSInteger section = -1;
    NSInteger currentRow = -1;
    BOOL foundSection = NO;
    for (int i = 0; i < _items.count; i++) {
        if (![_items[i] isKindOfClass:[ORSourceListItem class]]) {
            section++;
            if (section == path.section) {
                foundSection = YES;
            }
        }
        else if (foundSection) {
            currentRow++;
            if (currentRow == path.row) {
                return i;
            }
        }
    }
    return NSNotFound;
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

- (NSTextField *)textFieldForItems {
    NSTextField *titleLabel = [[NSTextField alloc] init];
    [titleLabel setBezeled:NO];
    [titleLabel setDrawsBackground:NO];
    [titleLabel setEditable:NO];
    [titleLabel setSelectable:NO];
    [[titleLabel cell] setBackgroundStyle:NSBackgroundStyleDark];
    titleLabel.font = [NSFont systemFontOfSize:12];
    titleLabel.textColor = self.textColor;
    return titleLabel;
}

- (NSTextField *)textFieldForHeaders {
    NSTextField *headerTextField = [self textFieldForItems];
    headerTextField.font = [NSFont boldSystemFontOfSize:12];
    headerTextField.textColor = [NSColor colorWithCalibratedRed:0.455 green:0.442 blue:0.459 alpha:1.000];
    return headerTextField;
}


- (void)tappedOnRightButton:(NSButton *)button {
    if ([_sourceListDelegate respondsToSelector:@selector(sourceList:didClickOnRightButtonForIndexPath:)]) {
        NSIndexPath *path = [self rowToIndexPath:button.tag];
        [_sourceListDelegate  sourceList:self didClickOnRightButtonForIndexPath:path];
    }
}

@end

@implementation ORSourceListHeaderView

- (id)initWithTitle:(NSString *)title sourceList:(ORSimpleSourceListView *)sourceList {
    self = [super init];
    if(!self)return nil;

    NSTextField *headerTextField = sourceList.textFieldForHeaders;
    self.textField = headerTextField;
    [self addSubview:headerTextField];
    
    NSImageView *itemImage = [[NSImageView alloc] init];
    self.imageView = itemImage;
    [self addSubview:itemImage];

    self.textField.stringValue = [title uppercaseString];
    return self;
}

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    
    self.textField.frame = CGRectMake(ORCellItemLeftPadding, -ORCellItemTopPadding, CGRectGetWidth(frameRect) - ORCellItemLeftPadding, ORCellHeight);
    self.imageView.frame = CGRectMake(ORCellLeftPadding, CGRectGetHeight(frameRect)/2 - ORCellImageDimensions/2, ORCellImageDimensions, ORCellImageDimensions);
}

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor colorWithCalibratedRed:0.162 green:0.137 blue:0.160 alpha:1.000]set];
    NSRectFill(dirtyRect);
}

@end

@implementation ORSourceListItemView {

    NSString *_thumbnail;
    NSString *_selectedThumbnail;
    NSString *_rightImageName;
    NSString *_rightImageActiveName;
    ORSimpleSourceListView *_sourceList;
}

- (id)initWithSourceListItem:(ORSourceListItem *)item sourceList:(ORSimpleSourceListView *)sourceList {
    self = [super init];
    if (!self)return nil;

    _thumbnail = item.thumbnail.copy;
    _selectedThumbnail = item.selectedThumbnail.copy;
    _rightImageName = item.rightButtonImage.copy;
    _rightImageActiveName = item.rightButtonActiveImage.copy;
    _sourceList = sourceList;

    NSTextField *titleTextField = [sourceList textFieldForItems];
    titleTextField.lineBreakMode = NSLineBreakByTruncatingTail;
    self.textField = titleTextField;
    [self addSubview:titleTextField];

    self.textField.stringValue = item. title;
    return self;
}

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];

    self.textField.frame = CGRectMake(ORCellItemLeftPadding, -ORCellItemTopPadding, CGRectGetWidth(frameRect) - ORCellItemLeftPadding, ORCellHeight);
    self.imageView.frame = CGRectMake(0, CGRectGetHeight(frameRect)/2 - ORCellImageDimensions/2, ORCellImageDimensions, ORCellImageDimensions);
}

@end

@implementation ORSourceListRowView

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        self.backgroundColor = [NSColor purpleColor];
    } else {
        self.backgroundColor = [NSColor clearColor];
    }
}

@end