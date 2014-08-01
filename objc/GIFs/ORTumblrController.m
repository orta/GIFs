//
//  ORTumblrController.m
//  GIFs
//
//  Created by orta therox on 21/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "ORTumblrController.h"
#import "AFNetworking.h"
#import "ORAppDelegate.h"
#import "GIF.h"

@interface TumblrGIF : GIF

@property (copy, nonatomic, readwrite) NSString *representedURL;
@property (assign, nonatomic, readwrite) NSInteger size;
@end

@implementation TumblrGIF @end

@implementation ORTumblrController {
    NSString *_url;
    NSArray *_gifs;

    NSInteger _offset;
    BOOL _downloading;
}

- (void)setTumblrURL:(NSString *)tumblrURL {

    _url = tumblrURL;
    _gifs = @[];
    _offset = 0;
    _downloading = NO;
}

- (void)getNextGIFs:(void (^)(NSArray *newGIFs, NSError *error))completion;
{
    if (_downloading) return;

    // http://whatshouldwecallme.tumblr.com/api/read/json

    NSString *address = [_url stringByAppendingFormat:@"/api/read/json?start=%@", @(_offset)];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *op = [manager GET:address parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        [ORAppDelegate setNetworkActivity:NO];
        _offset += 25;
        
        NSError *error = nil;
        NSString *string = [operation.responseString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
        NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
        NSMutableSet *newGIFs = [NSMutableSet set];

        [linkDetector enumerateMatchesInString:string
                                   options:0
                                     range:NSMakeRange(0, [string length])
                                usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
            if ([match resultType] == NSTextCheckingTypeLink) {
                NSURL *url = [match URL];

                if ([url.absoluteString rangeOfString:@".gif"].location != NSNotFound) {
                    NSString *address = [url.absoluteString stringByReplacingOccurrencesOfString:@"%5C" withString:@""];
                    GIF *gif = [[GIF alloc] initWithDownloadURL:address thumbnail:address andSource:nil];
                    if (gif) { [newGIFs addObject:gif]; }
                }
            }
        }];

        _gifs = [_gifs arrayByAddingObjectsFromArray:newGIFs.allObjects];
        _downloading = NO;
        if (completion) completion(newGIFs.allObjects, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) completion(nil, error);
    }];
    op.responseSerializer = [[AFHTTPResponseSerializer alloc] init];

    _downloading = YES;
    [ORAppDelegate setNetworkActivity:YES];
}

- (NSInteger)numberOfGifs {
    return _gifs.count;
}

- (GIF *)gifAtIndex:(NSInteger)index {
    return _gifs[index];
}

@end
