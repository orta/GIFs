//
//  ORSearchController.m
//  GIFs
//
//  Created by orta therox on 13/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "ORSearchController.h"
#import "AFNetworking.h"
#import "GIF.h"

@implementation ORSearchController {
    NSArray *_gifs;
    NSString *_query;
    NSString *_redditToken;
    BOOL _downloading;
}

- (void)setSearchQuery:(NSString *)query {
    _query = query;
    _gifs = @[];
    _redditToken = nil;
    _downloading = NO;
    [_gifViewController gotNewGIFs];
    [self getNextGIFs];
}


- (void)getNextGIFs {
    if (_downloading) return;

    NSString *address = nil;
    address = [NSString stringWithFormat:@"http://www.reddit.com/search.json?q=%@+url:*.gif&sort=relevance&t=all&restrict_sr=off&count=25", _query];
    if (_redditToken) {
        address = [address stringByAppendingFormat:@"&after=%@", _redditToken];
    }

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:address]];

    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

        _redditToken = JSON[@"data"][@"after"];
        NSArray *messages = JSON[@"data"][@"children"];
        NSMutableArray *mutableGifs = [NSMutableArray arrayWithArray:_gifs];

        for (NSDictionary *dictionary in messages) {
            GIF *gif = [[GIF alloc] initWithRedditDictionary:dictionary];
            if (gif) {
                [mutableGifs addObject:gif];
            }
        }

        _gifs = [NSArray arrayWithArray:mutableGifs];
        _downloading = NO;

        NSLog(@"found %lu from reddit", mutableGifs.count);
        [_gifViewController gotNewGIFs];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {

    }];

    _downloading = YES;
    [op start];
}


- (NSInteger)numberOfGifs {
    return _gifs.count;
}

- (GIF *)gifAtIndex:(NSInteger)index {
    return _gifs[index];
}

@end
