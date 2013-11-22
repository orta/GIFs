//
//  NSString+StringBetweenStrings.h
//  Artsy Folio
//
//  Created by orta therox on 03/10/2012.
//  Copyright (c) 2012 http://art.sy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (StringBetweenStrings)

// on a string "hello world" with arguments "e" and "d"
// will return "llo world" or nil if it can't find the start or end.

- (NSString *)substringBetween:(NSString *)start and:(NSString *)end;
@end
