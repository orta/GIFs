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
#import <GIFKit/GIF.h>

@interface TumblrGIF : GIF
@property (copy, nonatomic, readwrite) NSString *representedURL;
@property (copy, nonatomic, readwrite) NSString *tumblrID;

@property (assign, nonatomic, readwrite) NSInteger suffixIndex;
@property (assign, nonatomic, readwrite) BOOL isTumblr;
@end

@implementation TumblrGIF

+ (NSArray *)suffixes
{
    return @[@"75sq", @"100", @"250", @"300", @"400", @"500"];
}

- (void)setRepresentedURL:(NSString *)representedURL
{
    self.isTumblr = NO;
    
    for (NSString *size in self.class.suffixes ) {
        NSString *remove = [NSString stringWithFormat:@"_%@.gif", size];
        
        if ([representedURL containsString:remove]) {
            self.suffixIndex = [self.class.suffixes indexOfObject:size];
            self.isTumblr = YES;
        }
        representedURL = [representedURL stringByReplacingOccurrencesOfString:remove withString:@""];
    }
    
    if (self.isTumblr) {
        self.tumblrID = [[representedURL componentsSeparatedByString:@"tumblr.com"] lastObject];
    }
    _representedURL = representedURL;
}

- (id) imageRepresentation
{
    return self.downloadURL;
}

- (NSURL *)downloadURL
{
    if (!self.representedURL) return nil;
    
    if (self.isTumblr) {
        NSString *fullURL = [NSString stringWithFormat:@"%@_%@.gif",self.representedURL, self.class.suffixes[self.suffixIndex]];
        return  [NSURL URLWithString:fullURL];
    } else {
        return  [super downloadURL];
    }
}

- (NSUInteger)hash
{
    if (self.isTumblr) {
        return self.tumblrID.hash;
    } else {
        return self.representedURL.hash;
    }
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:self.class]) {
        if (self.isTumblr) {
            return [self.tumblrID isEqual:[object tumblrID]];
        } else {
            return [self.representedURL isEqual:[object representedURL]];
        }

    }
    return  [super isEqual:object];
}

@end

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
                    TumblrGIF *gif = [[TumblrGIF alloc] initWithDownloadURL:address thumbnail:address source:_url sourceTitle:_url ];
                    gif.representedURL = address;
                    if (gif) {
                        if ([newGIFs containsObject:gif]) {

                            // Set the suffix index to be the highest of the two
                            
                            for (TumblrGIF *searchGIF in newGIFs) {
                                if ([searchGIF.representedURL isEqualToString:gif.representedURL]) {
                                    searchGIF.suffixIndex = MAX(searchGIF.suffixIndex, gif.suffixIndex);
                                }
                            }
                        } else {
                            [newGIFs addObject:gif];
                        }

                    }
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
