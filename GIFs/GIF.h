//
//  GIF.h
//  GIFs
//
//  Created by orta therox on 12/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>

@interface GIF : NSObject

- (id)initWithRedditDictionary:(NSDictionary *)dictionary;

- (NSString *)imageUID;
- (NSString *)imageRepresentationType;
- (id) imageRepresentation;
- (NSURL *)downloadURL;

@end
