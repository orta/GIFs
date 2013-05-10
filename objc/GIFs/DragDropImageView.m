/*
     File: DragDropImageView.m 
 Abstract: Custom subclass of NSImageView with support for drag and drop operations. 
  Version: 1.1 
  
 Copyright (C) 2011 Apple Inc. All Rights Reserved. 
  
 */

#import "DragDropImageView.h"

@implementation DragDropImageView

@synthesize allowDrag;
@synthesize allowDrop;
@synthesize delegate;

NSString *kPrivateDragUTI = @"com.github.orta.gif";

- (id)initWithCoder:(NSCoder *)coder
{
    /*------------------------------------------------------
        Init method called for Interface Builder objects
    --------------------------------------------------------*/
    self=[super initWithCoder:coder];
    if ( self ) {
            //register for all the image types we can display
        [self registerForDraggedTypes:[NSImage imagePasteboardTypes]];
        self.allowDrag = YES;
        self.allowDrop = YES;
    }
    return self;
}

#pragma mark - Destination Operations

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    if (!self.allowDrop)
        return NSDragOperationNone;
    /*------------------------------------------------------
        method called whenever a drag enters our drop zone
     --------------------------------------------------------*/
    
            // Check if the pasteboard contains image data and source/user wants it copied
    if ( [NSImage canInitWithPasteboard:[sender draggingPasteboard]] &&
             [sender draggingSourceOperationMask] &
             NSDragOperationCopy ) {
            
            //highlight our drop zone
        highlight=YES;
            
        [self setNeedsDisplay: YES];
    
            /* When an image from one window is dragged over another, we want to resize the dragging item to
             * preview the size of the image as it would appear if the user dropped it in. */
        [sender enumerateDraggingItemsWithOptions:NSDraggingItemEnumerationConcurrent 
            forView:self
            classes:[NSArray arrayWithObject:[NSPasteboardItem class]] 
            searchOptions:nil 
            usingBlock:^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop) {
                
                    /* Only resize a fragging item if it originated from one of our windows.  To do this,
                     * we declare a custom UTI that will only be assigned to dragging items we created.  Here
                     * we check if the dragging item can represent our custom UTI.  If it can't we stop. */
                if ( ![[[draggingItem item] types] containsObject:kPrivateDragUTI] ) {
                    
                    *stop = YES;
                    
                } else {
                        /* In order for the dragging item to actually resize, we have to reset its contents.
                         * The frame is going to be the destination view's bounds.  (Coordinates are local 
                         * to the destination view here).
                         * For the contents, we'll grab the old contents and use those again.  If you wanted
                         * to perform other modifications in addition to the resize you could do that here. */
                    [draggingItem setDraggingFrame:self.bounds contents:[[[draggingItem imageComponents] objectAtIndex:0] contents]];
                }
            }];
        
        //accept data as a copy operation
        return NSDragOperationCopy;
    }
    
    return NSDragOperationNone;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    /*------------------------------------------------------
       method called whenever a drag exits our drop zone
    --------------------------------------------------------*/
        //remove highlight of the drop zone
    highlight=NO;
    
    [self setNeedsDisplay: YES];
}

-(void)drawRect:(NSRect)rect
{
    /*------------------------------------------------------
        draw method is overridden to do drop highlighing
    --------------------------------------------------------*/
        //do the usual draw operation to display the image
    [super drawRect:rect];
    
    if ( highlight ) {
            //highlight by overlaying a gray border
        [[NSColor grayColor] set];
        [NSBezierPath setDefaultLineWidth: 5];
        [NSBezierPath strokeRect: rect];
    }
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    /*------------------------------------------------------
        method to determine if we can accept the drop
    --------------------------------------------------------*/
        //finished with the drag so remove any highlighting
    highlight=NO;
    
    [self setNeedsDisplay: YES];
    
        //check to see if we can accept the data
    return [NSImage canInitWithPasteboard: [sender draggingPasteboard]];
} 

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    /*------------------------------------------------------
        method that should handle the drop data
    --------------------------------------------------------*/
    if ([sender draggingSource] != self ) {
        NSURL* fileURL;

            //set the image using the best representation we can get from the pasteboard
        if([NSImage canInitWithPasteboard: [sender draggingPasteboard]]) {
            NSImage *newImage = [[NSImage alloc] initWithPasteboard: [sender draggingPasteboard]];
            [self setImage:newImage];
//            NSRect selfFrame = self.frame;
//            selfFrame.size = newImage.size;
//            selfFrame.origin = CGPointMake(0, 0);
//            self.frame = selfFrame;
//            self.superview.frame = self.frame;
//            [newImage release];
        }
        
            //if the drag comes from a file, set the window title to the filename
        fileURL=[NSURL URLFromPasteboard: [sender draggingPasteboard]];
//        [[self window] setTitle: fileURL!=NULL ? [fileURL absoluteString] : @"(no name)"];
        if ([self.delegate respondsToSelector:@selector(dropComplete:)]) {
            [self.delegate dropComplete:[fileURL path]];
        }
    }
    
    return YES;
}

- (NSRect)windowWillUseStandardFrame:(NSWindow *)window defaultFrame:(NSRect)newFrame;
{
    /*------------------------------------------------------
       delegate operation to set the standard window frame
    --------------------------------------------------------*/
        //get window frame size
    NSRect ContentRect=self.window.frame;
    
        //set it to the image frame size
    ContentRect.size=[[self image] size];
    
    return [NSWindow frameRectForContentRect:ContentRect styleMask: [window styleMask]];
};

#pragma mark - Source Operations

- (void)mouseDown:(NSEvent*)event
{
    if (self.allowDrag) {
        NSPoint dragPosition;
        NSRect imageLocation;
        
        dragPosition = [self convertPoint:[event locationInWindow] fromView:nil];
        dragPosition.x -= 16;
        dragPosition.y -= 16;
        imageLocation.origin = dragPosition;
        imageLocation.size = NSMakeSize(32,32);
        [self dragPromisedFilesOfTypes:[NSArray arrayWithObject:NSPasteboardTypeTIFF] fromRect:imageLocation source:self slideBack:YES event:event];
    }
}

- (void)dragImage:(NSImage *)anImage at:(NSPoint)viewLocation offset:(NSSize)initialOffset event:(NSEvent *)event pasteboard:(NSPasteboard *)pboard source:(id)sourceObj slideBack:(BOOL)slideFlag
{
    if (!self.image) return;
    
    //create a new image for our semi-transparent drag image
    NSImage* dragImage=[[NSImage alloc] initWithSize:[[self image] size]]; 
    
    [dragImage lockFocus];//draw inside of our dragImage
    //draw our original image as 50% transparent
    [[self image] dissolveToPoint: NSZeroPoint fraction: .5];
    [dragImage unlockFocus];//finished drawing
    [dragImage setScalesWhenResized:NO];//we want the image to resize
    [dragImage setSize:[self bounds].size];//change to the size we are displaying
    
    [super dragImage:dragImage at:self.bounds.origin offset:NSZeroSize event:event pasteboard:pboard source:sourceObj slideBack:slideFlag];
}

- (NSArray *)namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination
{
    NSArray *representations;
    NSData *bitmapData;
    
    representations = [[self image] representations];
    
    if ([[[representations objectAtIndex:0] className] isEqualToString:@"NSBitmapImageRep"]) {
        bitmapData = [NSBitmapImageRep representationOfImageRepsInArray:representations
                                                              usingType:NSGIFFileType properties:nil];
    }     
    [bitmapData writeToFile:[[dropDestination path] stringByAppendingPathComponent:@"test.gif"]  atomically:YES];
    return [NSArray arrayWithObjects:@"test.gif", nil];
}

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
    /*------------------------------------------------------
     NSDraggingSource protocol method.  Returns the types of operations allowed in a certain context.
     --------------------------------------------------------*/
    switch (context) {
        case NSDraggingContextOutsideApplication:
            return NSDragOperationCopy;
            
            //by using this fall through pattern, we will remain compatible if the contexts get more precise in the future.
        case NSDraggingContextWithinApplication:
        default:
            return NSDragOperationCopy;
            break;
    }
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event 
{
    /*------------------------------------------------------
        accept activation click as click in window
    --------------------------------------------------------*/
        //so source doesn't have to be the active window
    return YES;
}

- (void)pasteboard:(NSPasteboard *)sender item:(NSPasteboardItem *)item provideDataForType:(NSString *)type
{
    /*------------------------------------------------------
       	method called by pasteboard to support promised 
        drag types.
    --------------------------------------------------------*/
        //sender has accepted the drag and now we need to send the data for the type we promised
    if ( [type compare: NSPasteboardTypeTIFF] == NSOrderedSame ) {
        
            //set data for TIFF type on the pasteboard as requested
        [sender setData:[[self image] TIFFRepresentation] forType:NSPasteboardTypeTIFF];
        
    } else if ( [type compare: NSPasteboardTypePDF] == NSOrderedSame ) {
        
            //set data for PDF type on the pasteboard as requested
        [sender setData:[self dataWithPDFInsideRect:[self bounds]] forType:NSPasteboardTypePDF];
    }
    
}
@end
