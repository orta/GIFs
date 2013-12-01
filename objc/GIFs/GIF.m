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
    NSString *_sourceURL;

}

- (id)initWithRedditDictionary:(NSDictionary *)dictionary {

    NSString *thumbnailURL = dictionary[@"data"][@"thumbnail"];
    NSString *downloadURL = dictionary[@"data"][@"url"];
    NSString *sourceURL = [NSString stringWithFormat:@"http://reddit.com%@", dictionary[@"data"][@"permalink"]];

    if (thumbnailURL.length == 0) {
        if ([downloadURL rangeOfString:@"imgur"].location != NSNotFound) {
            thumbnailURL = [downloadURL stringByReplacingOccurrencesOfString:@".gif" withString:@"b.jpg"];


        } else {
            // ergh, this would take a while
            thumbnailURL = downloadURL;
        }
    }

    downloadURL = [downloadURL stringByReplacingOccurrencesOfString:@"http://imgur.com/" withString:@"http://imgur.com/download/"];

    // http://imgur.com/download/a/1iZuu -> http://i.imgur.com/3r3yeIz.gif

    if ([downloadURL hasPrefix:@"http://imgur.com/download/a/"]) {
        downloadURL = [downloadURL stringByReplacingOccurrencesOfString:@"http://imgur.com/download/a/" withString:@""];
        downloadURL = [NSString stringWithFormat:@"http://i.imgur.com/%@.gif", downloadURL];
    }

    // http://gifsound.com/?gif=http%3A%2F%2Fi.imgur.com%2FWcpOt.gif&sound=http%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3DZii3FYWaE4I&start=0  ->  http://i.imgur.com/3r3yeIz.gif

    if ([downloadURL hasPrefix:@"http://gifsound.com/?gif="]) {
        downloadURL = [downloadURL stringByReplacingOccurrencesOfString:@"http://gifsound.com/?gif=" withString:@""];
        downloadURL = [downloadURL componentsSeparatedByString:@"&amp;sound="][0];
        downloadURL = [downloadURL stringByRemovingPercentEncoding];
    }

    if ([downloadURL hasPrefix:@"http://imgur.com/download/gallery/"]) {
        return nil;
    }

    if ([downloadURL rangeOfString:@"imgur"].location == NSNotFound && [downloadURL rangeOfString:@"media.tumblr.com"].location == NSNotFound) {
        return nil;
    }

    self = [self initWithDownloadURL:downloadURL thumbnail:thumbnailURL andSource:sourceURL];
    return self;
}

- (id)initWithDownloadURL:(NSString *)downloadURL thumbnail:(NSString *)thumbnail andSource:(NSString *)source {
    self = [super init];

    _thumbnailURL = thumbnail;
    _downloadURL = downloadURL;
    _sourceURL = source;

    return self;
}

#define downloadKey       @"download"
#define thumbnailKey      @"thumbnail"
#define dateAddedKey      @"dateAdded"
#define sourceKey         @"source"


- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_thumbnailURL forKey:thumbnailKey];
    [encoder encodeObject:_downloadURL forKey:downloadKey];
    [encoder encodeObject:_dateAdded forKey:dateAddedKey];
    [encoder encodeObject:_sourceURL forKey:sourceKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSString *thumbnail = [decoder decodeObjectForKey:thumbnailKey];
    NSString *download = [decoder decodeObjectForKey:downloadKey];
    NSString *source = [decoder decodeObjectForKey:sourceKey];
    NSDate *date = [decoder decodeObjectForKey:dateAddedKey];

    GIF *gif = [[self.class  alloc] initWithDownloadURL:download thumbnail:thumbnail andSource:source];
    gif.dateAdded = date;
    return gif;
}

- (NSString *)imageUID {
    return _downloadURL;
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

- (NSURL *)sourceURL {
    if (!_sourceURL) return nil;
    return  [NSURL URLWithString:_sourceURL];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@", NSStringFromClass(self.class), self.imageUID];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:self.class]) {
        return [self.imageUID isEqualToString:[object imageUID]];
    }
    return  [super isEqual:object];
}

@end
