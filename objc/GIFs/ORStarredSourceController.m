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
    BOOL done;
}

- (void)reloadData
{
    NSString *path = [[NSFileManager defaultManager] pathForPrivateFile:@"starred.data"];
    NSSet *data = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (data) {
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateAdded" ascending:NO];
        _starred = [data sortedArrayUsingDescriptors:@[descriptor]];
        done = NO;
    }
}

- (void)getNextGIFs {
//    if(done) return;
//
//    done = YES;
//    [_gifController gotNewGIFs];
}


- (NSInteger)numberOfGifs {
    return _starred.count;
}

- (GIF *)gifAtIndex:(NSInteger)index {
    return _starred[index];
}

@end
