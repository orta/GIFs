//
//  ORSharingController.m
//  GIFs
//
//  Created by orta therox on 20/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "ORSharingController.h"
#import "SBSystemPreferences.h"


@implementation ORSharingController {
    NSSharingService *_tweetSharingService;
    NSSharingService *_emailSharingService;
    NSSharingService *_facebookSharingService;

}

- (void)awakeFromNib {
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

}

- (IBAction)twitterClicked:(id)sender {
    if ([_tweetSharingService canPerformWithItems:nil]) {
        GIF *gif = _gifController.currentGIF;

    }
    else {

    }

}

- (IBAction)facebookClicked:(id)sender {
    if ([_facebookSharingService canPerformWithItems:nil]) {

    }
    else {
        
    }
}

- (IBAction)emailClicked:(id)sender {
    
}

- (void)openAccounts {
    SBSystemPreferencesApplication *systemPrefs =
    [SBApplication applicationWithBundleIdentifier:@"com.apple.systempreferences"];

    [systemPrefs activate];

    SBElementArray *panes = [systemPrefs panes];
    SBSystemPreferencesPane *accountsPane = nil;

    for (SBSystemPreferencesPane *pane in panes) {
        if ([[pane id] isEqualToString:@"com.apple.preferences.internetaccounts"]) {
            accountsPane = pane;
            break;
        }
    }
    
    [systemPrefs setCurrentPane:accountsPane];

    SBElementArray *anchors = [accountsPane anchors];

    for (SBSystemPreferencesAnchor *anchor in anchors) {
        if ([anchor.name isEqualToString:@"TTS"]) {
            [anchor reveal];
        }
    }
}

@end
