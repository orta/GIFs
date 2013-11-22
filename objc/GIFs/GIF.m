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

    NSString *thumbnailURL = dictionary[@"data"][@"thumbnail"];
   NSString *downloadURL = dictionary[@"data"][@"url"];

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

    self = [self initWithDownloadURL:downloadURL andThumbnail:thumbnailURL];
    return self;
}

- (id)initWithDownloadURL:(NSString *)downloadURL andThumbnail:(NSString *)thumbnail {
    self = [super init];

    _thumbnailURL = thumbnail;
    _downloadURL = downloadURL;

    return self;
}

#define downloadKey       @"download"
#define thumbnailKey      @"thumbnail"
#define dateAddedKey      @"dateAdded"

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_thumbnailURL forKey:thumbnailKey];
    [encoder encodeObject:_downloadURL forKey:downloadKey];
    [encoder encodeObject:_dateAdded forKey:dateAddedKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSString *thumbnail = [decoder decodeObjectForKey:thumbnailKey];
    NSString *download = [decoder decodeObjectForKey:downloadKey];
    NSDate *date = [decoder decodeObjectForKey:dateAddedKey];

    GIF *gif = [[self.class  alloc] initWithDownloadURL:download andThumbnail:thumbnail];
    gif.dateAdded = date;
    return gif;
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
