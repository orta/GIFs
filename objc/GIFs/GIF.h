//
//  GIF.h
//  GIFs
//
//  Created by orta therox on 12/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>

@interface GIF : NSObject <NSCoding>

- (id)initWithRedditDictionary:(NSDictionary *)dictionary;
- (id)initWithDownloadURL:(NSString *)downloadURL andThumbnail:(NSString *)thumbnail;

- (NSString *)imageUID;
- (NSString *)imageRepresentationType;
- (id) imageRepresentation;
- (NSURL *)downloadURL;

@property (strong) NSDate *dateAdded;

@end
