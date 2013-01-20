//
//  ORGIFController.m
//  GIFs
//
//  Created by orta therox on 13/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "ORGIFController.h"
#import "ORRedditImageController.h"
#import "ORSearchController.h"
#import "GIF.h"

@implementation ORGIFController {
    NSObject <ORGIFSource> *_currentSource;
}

- (void)getGIFsFromSourceString:(NSString *)string {
    if([string rangeOfString:@"reddit"].location != NSNotFound){
        _currentSource = _redditController;
        _searchController.gifViewController = self;
        [_redditController setRedditURL:string];
    } else {
        _currentSource = _searchController;
        _searchController.gifViewController = self;
        [_searchController setSearchQuery:string];
    }
    [_imageBrowser reloadData];
}

- (void)awakeFromNib {
    [_imageBrowser setValue:[NSColor colorWithCalibratedRed:0.955 green:0.950 blue:0.970 alpha:1.000] forKey:IKImageBrowserBackgroundColorKey];
    [[_imageBrowser superview] setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myTableClipBoundsChanged:)
                                                 name:NSViewBoundsDidChangeNotification object:[_imageBrowser superview]];
}

- (void)myTableClipBoundsChanged:(NSNotification *)notification {
    NSClipView *clipView = [notification object];
    NSRect newClipBounds = [clipView bounds];
    CGFloat height = _imageScrollView.contentSize.height;

    if (CGRectGetMinY(newClipBounds) + CGRectGetHeight(newClipBounds) < height + 20) {
        NSLog(@"get next from height");
        [_currentSource getNextGIFs];
    }
}

- (void)gotNewGIFs {
    [_imageBrowser reloadData];
}

- (NSUInteger) numberOfItemsInImageBrowser:(IKImageBrowserView *) aBrowser {
    return _currentSource.numberOfGifs;
}

- (id) imageBrowser:(IKImageBrowserView *)aBrowser itemAtIndex:(NSUInteger)index {
    return [_currentSource gifAtIndex:index];;
}

- (void) imageBrowserSelectionDidChange:(IKImageBrowserView *) aBrowser {
    NSInteger index = [[aBrowser selectionIndexes] lastIndex];

    if (index != NSNotFound) {
        GIF *gif = [_currentSource gifAtIndex:index];

        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"gif_template" ofType:@"html"];
        NSString *html = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:nil];
        html = [html stringByReplacingOccurrencesOfString:@"{{OR_IMAGE_URL}}" withString:gif.downloadURL.absoluteString];
        if (html) {
            [[_webView mainFrame] loadHTMLString:html baseURL:nil];
        }
    }
}

@end
