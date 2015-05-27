//
//  ORGIFRightClickMenuMaker.h
//  GIFs
//
//  Created by Orta on 8/20/14.
//  Copyright (c) 2014 Orta Therox. All rights reserved.
//

@interface ORGIFRightClickMenuMaker : NSObject

- (instancetype)initWithGIF:(GIF *)gif;
@property (readonly, nonatomic, strong) GIF *gif;

- (NSMenu *)menu;
- (NSArray *)menuItems;
@end
