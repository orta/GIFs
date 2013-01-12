//
//  ORImaageView.m
//  GIFs
//
//  http://blog.pcitron.fr/2010/12/14/play-an-animated-gif-with-an-ikimageview/

#import "ORImageView.h"

@implementation ORImageView

-(void)awakeFromNib
{
    // create an overlay for the image (which is used to play animated gifs)
    // EDIT: well, don't do that here, due to some initialization orders
    //       problem, it might gives an error and not create the overlay
    //       I leave that line here for the records ^^
    //[self setOverlay:[CALayer layer] forType:IKOverlayTypeImage];

    // NOTE: calling this before anything else seems to fix a lot of
    //       problems ... maybe it's initializing a few things internally
    //       on the first call ...
    [super setImageWithURL:nil];
}

-(BOOL)isGIF:(NSString *)path
{
    return YES;
    // checks if the path points to a GIF image
    NSString * pathExtension = [[path pathExtension] lowercaseString];
    return [pathExtension isEqualToString:@"gif"];
}

-(void)setImageWithURL:(NSURL *)url
{
    // EDIT: this is where we create the overlay now, but only if it doesn't
    //       already exists.
    // checks if a layer is already set
    if ([self overlayForType:IKOverlayTypeImage] == nil)
        [self setOverlay:[CALayer layer] forType:IKOverlayTypeImage];

    // remove the overlay animation
    [[self overlayForType:IKOverlayTypeImage] removeAllAnimations];

    // check if it's a gif
    if ([self isGIF:[url path]] == YES)
    {
        // loads the image
        NSImage * image = [[NSImage alloc] initWithContentsOfFile:[url path]];

        // get the image representations, and iterate through them
        NSArray * reps = [image representations];
        for (NSImageRep * rep in reps)
        {
            // find the bitmap representation
            if ([rep isKindOfClass:[NSBitmapImageRep class]] == YES)
            {
                // get the bitmap representation
                NSBitmapImageRep * bitmapRep = (NSBitmapImageRep *)rep;

                // get the number of frames. If it's 0, it's not an animated gif, do nothing
                int numFrame = [[bitmapRep valueForProperty:NSImageFrameCount] intValue];
                if (numFrame == 0)
                    break;

                // create a value array which will contains the frames of the animation
                NSMutableArray * values = [NSMutableArray array];

                // loop through the frames (animationDuration is the duration of the whole animation)
                float animationDuration = 0.0f;
                for (int i = 0; i < numFrame; ++i)
                {
                    // set the current frame
                    [bitmapRep setProperty:NSImageCurrentFrame withValue:[NSNumber numberWithInt:i]];

                    // this part is optional. For some reasons, the NSImage class often loads a GIF with
                    // frame times of 0, so the GIF plays extremely fast. So, we check the frame duration, and if it's
                    // less than a threshold value, we set it to a default value of 1/20 second.
                    if ([[bitmapRep valueForProperty:NSImageCurrentFrameDuration] floatValue] < 0.000001f)
                        [bitmapRep setProperty:NSImageCurrentFrameDuration withValue:[NSNumber numberWithFloat:1.0f / 20.0f]];

                    // add the CGImageRef to this frame to the value array
                    [values addObject:(id)[bitmapRep CGImage]];

                    // update the duration of the animation
                    animationDuration += [[bitmapRep valueForProperty:NSImageCurrentFrameDuration] floatValue];
                }

                // create and setup the animation (this is pretty straightforward)
                CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
                [animation setValues:values];
                [animation setCalculationMode:@"discrete"];
                [animation setDuration:animationDuration];
                [animation setRepeatCount:HUGE_VAL];

                // add the animation to the layer
                [[self overlayForType:IKOverlayTypeImage] addAnimation:animation forKey:@"contents"];

                // stops at the first valid representation
                break;
            }
        }
    }
    
    // calls the super setImageWithURL method to handle standard images
    [super setImageWithURL:url];
}

@end
