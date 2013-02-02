//
//  ORSharingController.m
//  GIFs
//
//  Created by orta therox on 20/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "ORSharingController.h"


@implementation ORSharingController {
    NSSharingService *_tweetSharingService;
    NSSharingService *_emailSharingService;
    NSSharingService *_facebookSharingService;

}

- (void)awakeFromNib {
    _mainImageView.allowDrag = YES;
    _mainImageView.allowDrop = NO;
    
    _emailSharingService = [NSSharingService sharingServiceNamed:NSSharingServiceNameComposeEmail];
    _emailButton.image = _emailSharingService.image;
    _emailButton.alternateImage = _emailSharingService.alternateImage;

    
    _tweetSharingService = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTwitter];
    _twitterButton.image = _tweetSharingService.image;
    _twitterButton.alternateImage = _tweetSharingService.alternateImage;


    _facebookSharingService = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnFacebook];
    _facebookButton.image = _facebookSharingService.image;
    _facebookButton.alternateImage = _facebookSharingService.alternateImage;

    [@[_emailSharingService, _tweetSharingService, _facebookSharingService] enumerateObjectsUsingBlock:^(NSSharingService *obj, NSUInteger idx, BOOL *stop) {
        [obj setDelegate:self];
    }];

    [_miscButton sendActionOn:NSLeftMouseDownMask];
}

- (IBAction)miscClicked:(id)sender {
    NSMutableArray *shareItems = [@[@"HALLO I MADES IT"] mutableCopy];

    NSImage *image = [_mainImageView image];
    if (image) {
        [shareItems addObject:image];
    }

    NSSharingServicePicker *sharingServicePicker = [[NSSharingServicePicker alloc] initWithItems:shareItems];

    sharingServicePicker.delegate = self;
    [sharingServicePicker showRelativeToRect:[_miscButton bounds] ofView:_miscButton preferredEdge:NSMaxYEdge];
}

- (IBAction)twitterClicked:(id)sender {
    if ([_tweetSharingService canPerformWithItems:nil]) {
        
    }
    else {

    }
    
    [self shareOnService:_tweetSharingService];
}

- (IBAction)facebookClicked:(id)sender {
    // Ideally we should do GIF -> Movie here
    //    http://www.idevgames.com/forums/thread-4283.html

    if ([_facebookSharingService canPerformWithItems:nil]) {

    }
    else {
        
    }
        [self shareOnService:_facebookSharingService];
}


- (IBAction)emailClicked:(id)sender {
    [self shareOnService:_emailSharingService];
}

- (void)shareOnService:(NSSharingService *)service {
//    GIF *gif = _gifController.currentGIF;
    NSMutableArray *shareItems = [@[@"HALLO I MADES IT"] mutableCopy];

    NSURL *data = [NSURL fileURLWithPath: _gifController.gifFilePath];
    if (data) {
        [shareItems addObject:data];
    }
    [service performWithItems:shareItems];
}


- (NSWindow *)sharingService:(NSSharingService *)sharingService sourceWindowForShareItems:(NSArray *)items sharingContentScope:(NSSharingContentScope *)sharingContentScope {
    return _mainImageView.window;
}



- (NSRect)sharingService:(NSSharingService *)sharingService sourceFrameOnScreenForShareItem:(id<NSPasteboardWriting>)item {
        NSImageView *imageView = _mainImageView;
        NSRect imageViewBounds = [imageView bounds];
        NSSize imageSize = [[imageView image] size];
        NSRect imageFrame = NSMakeRect((NSWidth(imageViewBounds) - imageSize.width) / 2.0, (NSHeight(imageViewBounds) - imageSize.height) / 2.0, imageSize.width, imageSize.height);
        NSRect frame = [imageView convertRect:imageFrame toView:nil];
        frame.origin = [[imageView window] convertBaseToScreen:frame.origin];
        return frame;
}


- (NSImage *)sharingService:(NSSharingService *)sharingService transitionImageForShareItem:(id<NSPasteboardWriting>)item contentRect:(NSRect *)contentRect
{

        return [_mainImageView image];
}
@end
