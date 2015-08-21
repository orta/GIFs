//
//  ORStarredSourceController.m
//  GIFs
//
//  Created by Orta on 21/11/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "ORStarredSourceController.h"
#import <StandardPaths/StandardPaths.h>


@implementation ORStarredSourceController {
    NSArray *_starred;
}

- (void)awakeFromNib {
    [self reloadData];
}

- (void)reloadData
{
    NSString *path = [[NSFileManager defaultManager] pathForPrivateFile:@"starred.data"];
    NSSet *data = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (data) {
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateAdded" ascending:NO];
        _starred = [data sortedArrayUsingDescriptors:@[descriptor]];
    }
}

- (void)getNextGIFs:(void (^)(NSArray *, NSError *))completion {
    
}


- (NSInteger)numberOfGifs {
    return _starred.count;
}

- (GIF *)gifAtIndex:(NSInteger)index {
    return _starred[index];
}

- (BOOL)hasGIFWithDownloadAddress:(NSString *)address
{
    for (GIF *gif in _starred) {
        if ([gif.imageUID isEqualToString:address]) {
            return YES;
        }
    }
    return NO;
}

@end
