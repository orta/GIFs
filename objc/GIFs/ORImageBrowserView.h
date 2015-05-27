//
//  ORImageBrowserView.h
//  GIFs
//
//  Created by Orta on 8/24/14.
//  Copyright (c) 2014 Orta Therox. All rights reserved.
//

#import <Quartz/Quartz.h>

@protocol ORImageBrowserViewDelegate <NSObject>

- (NSURL *)URLForCurrentGIF;
- (NSURL *)URLForCurrentGIFContext;
- (NSString *)sourceTitleForCurrentGIF;

@end

@interface ORImageBrowserView : IKImageBrowserView

@property (nonatomic, weak) IBOutlet id <ORImageBrowserViewDelegate> gifDelegate;

@end

@interface ORImageBrowserCell : IKImageBrowserCell

@end