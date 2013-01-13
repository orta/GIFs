//
//  ORMenuController.m
//  GIFs
//
//  Created by orta therox on 12/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "ORMenuController.h"

@implementation ORMenuController {
    NSDictionary *_sources;
    NSArray *_searches;
}

- (void)awakeFromNib {
    _sources = @{
                    @"/r/GIFs": @"http://www.reddit.com/r/gifs.json",
                    @"/r/GIF": @"http://www.reddit.com/r/gif.json",
                    @"/r/WhitePeopleGIFs": @"http://www.reddit.com/r/whitepeoplegifs.json",
                    @"/r/BlackPeopleGIFs": @"http://www.reddit.com/r/blackpeoplegifs.json",
                    @"/r/ReactionGIFs": @"http://www.reddit.com/r/reactiongifs.json"
                };
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
        result.textField.stringValue = _sources.allKeys[row];
    }
    return result;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView *tableView = notification.object;
    NSInteger index = [tableView selectedRow];
    
    if (index == NSNotFound && index != -1) {
        return;
    }

    if(index < _searches.count){
        [_gifViewController getGIFsFromSourceString:_searches[index]];
    } else {
        [_gifViewController getGIFsFromSourceString:_sources.allValues[index]];
    }
}

@end
