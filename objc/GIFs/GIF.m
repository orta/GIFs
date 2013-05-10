//
//  GIF.m
//  GIFs
//
//  Created by orta therox on 12/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "GIF.h"

@implementation GIF {
    NSString *_thumbnailURL;
    NSString *_downloadURL;
}

- (id)initWithRedditDictionary:(NSDictionary *)dictionary {
    self = [super init];

    _thumbnailURL = dictionary[@"data"][@"thumbnail"];
    _downloadURL = dictionary[@"data"][@"url"];

    if (_thumbnailURL.length == 0) {
        if ([_downloadURL rangeOfString:@"imgur"].location != NSNotFound) {
            _thumbnailURL = [_downloadURL stringByReplacingOccurrencesOfString:@".gif" withString:@"b.jpg"];

        } else {
            // ergh, this would take a while
            _thumbnailURL = _downloadURL;
        }
    }

    _downloadURL = [_downloadURL stringByReplacingOccurrencesOfString:@"http://imgur.com/" withString:@"http://imgur.com/download/"];
    if ([_downloadURL rangeOfString:@"imgur"].location == NSNotFound) {
        return nil;
    }

    return self;
}

- (id)initWithDownloadURL:(NSString *)downloadURL andThumbnail:(NSString *)thumbnail {
    self = [super init];

    _thumbnailURL = thumbnail;
    _downloadURL = downloadURL;

    return self;
}

- (NSString *)imageUID {
    return _thumbnailURL;
}

- (NSString *)imageRepresentationType {
    return IKImageBrowserNSURLRepresentationType;
}

- (id) imageRepresentation {
    return [NSURL URLWithString:_thumbnailURL];
}

- (NSURL *)downloadURL {
    return  [NSURL URLWithString:_downloadURL];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:self.class]) {
        return [self.imageUID isEqual:[object imageUID]];
    }
    return  [super isEqual:object];
}

@end
