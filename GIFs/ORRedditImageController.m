//
//  ORRedditImageController.m
//  GIFs
//
//  Created by orta therox on 12/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "ORRedditImageController.h"
#import "AFNetworking.h"
#import "GIF.h"

@implementation ORRedditImageController {
    NSString *_url;
    NSArray *_gifs;
    NSString *_token;

    BOOL _downloading;
}

- (void)awakeFromNib {
    [[_imageBrowser superview] setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myTableClipBoundsChanged:)
                                                 name:NSViewBoundsDidChangeNotification object:[_imageBrowser superview]];

}

- (void)myTableClipBoundsChanged:(NSNotification *)notification {
    NSClipView *clipView = [notification object];
    NSRect newClipBounds = [clipView bounds];
    CGFloat height = _imageScrollView.contentSize.height;
    if (CGRectGetMinY(newClipBounds) + CGRectGetHeight(newClipBounds) > height - 10) {
        [self getNextGIFs];
    }
    
    NSLog(@"%@", NSStringFromRect(newClipBounds));
    NSLog(@"%f > %f ", CGRectGetMinY(newClipBounds), height);
}


- (void)setRedditURL:(NSString *)redditURL {
    _url = redditURL;
    _gifs = @[];
    [_imageBrowser reloadData];
    _downloading = NO;
    
    [self getNextGIFs];
}

- (void)getNextGIFs {
    if (_downloading) return;
    
    NSString *address = _url;
    if (_token) {
        address = [address stringByAppendingFormat:@"?after=%@", _token];
    }

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:address]];

    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        _token = JSON[@"data"][@"after"];
        NSArray *messages = JSON[@"data"][@"children"];
        NSMutableArray *mutableGifs = [NSMutableArray arrayWithArray:_gifs];

        for (NSDictionary *dictionary in messages) {
            GIF *gif = [[GIF alloc] initWithRedditDictionary:dictionary];
            if (gif) {
                [mutableGifs addObject:gif];
            }
        }
        _gifs = [NSArray arrayWithArray:mutableGifs];
        _downloading = NO;
        [_imageBrowser reloadData];

    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {

    }];

    _downloading = YES;
    [op start];
}

- (NSUInteger) numberOfItemsInImageBrowser:(IKImageBrowserView *) aBrowser {
    return _gifs.count;
}

- (id) imageBrowser:(IKImageBrowserView *)aBrowser itemAtIndex:(NSUInteger)index {
    return _gifs[index];
}

- (void) imageBrowserSelectionDidChange:(IKImageBrowserView *) aBrowser {
    NSInteger index = [[aBrowser selectionIndexes] lastIndex];
    
    if (index != NSNotFound) {
        GIF *gif = _gifs[index];
        NSURLRequest *request = [NSURLRequest requestWithURL:gif.downloadURL];
        [[_webView mainFrame] loadRequest:request];
        
//        [_largeImageView setImageWithURL:gif.imageRepresentation];
    }
}



@end
