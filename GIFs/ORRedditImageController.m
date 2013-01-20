//
//  ORRedditImageController.m
//  GIFs
//
//  Created by orta therox on 12/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "ORRedditImageController.h"
#import "AFNetworking.h"
#import "GIF.h"
#import "ORAppDelegate.h"

@implementation ORRedditImageController {
    NSString *_url;
    NSArray *_gifs;
    NSString *_token;

    BOOL _downloading;
}

- (void)setRedditURL:(NSString *)redditURL {
    _url = redditURL;
    _gifs = @[];
    _token = nil;
    _downloading = NO;

    
    [self getNextGIFs];
}

- (void)getNextGIFs {
    if (_downloading) return;
    
    NSString *address = _url;
    if (_token) {
        address = [address stringByAppendingFormat:@"?after=%@", _token];
    }

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:address]];

    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            [ORAppDelegate setNetworkActivity:NO];
        _token = JSON[@"data"][@"after"];
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

        [_gifController gotNewGIFs];

        if (_gifs.count < 21) {
            [self performSelectorOnMainThread:@selector(getNextGIFs) withObject:nil waitUntilDone:NO];
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [ORAppDelegate setNetworkActivity:NO];
        
    }];

    _downloading = YES;
    [op start];
    [ORAppDelegate setNetworkActivity:YES];
}


- (NSInteger)numberOfGifs {
    return _gifs.count;
}

- (GIF *)gifAtIndex:(NSInteger)index {
    return _gifs[index];
}

@end
