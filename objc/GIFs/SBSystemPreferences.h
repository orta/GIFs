/*
 * SBSystemPreferences.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class SBSystemPreferencesItem, SBSystemPreferencesApplication, SBSystemPreferencesColor, SBSystemPreferencesDocument, SBSystemPreferencesWindow, SBSystemPreferencesAttributeRun, SBSystemPreferencesCharacter, SBSystemPreferencesParagraph, SBSystemPreferencesText, SBSystemPreferencesAttachment, SBSystemPreferencesWord, SBSystemPreferencesAnchor, SBSystemPreferencesPane, SBSystemPreferencesPrintSettings;

enum SBSystemPreferencesSavo {
	SBSystemPreferencesSavoAsk = 'ask ' /* Ask the user whether or not to save the file. */,
	SBSystemPreferencesSavoNo = 'no  ' /* Do not save the file. */,
	SBSystemPreferencesSavoYes = 'yes ' /* Save the file. */
};
typedef enum SBSystemPreferencesSavo SBSystemPreferencesSavo;

enum SBSystemPreferencesEnum {
	SBSystemPreferencesEnumStandard = 'lwst' /* Standard PostScript error handling */,
	SBSystemPreferencesEnumDetailed = 'lwdt' /* print a detailed report of PostScript errors */
};
typedef enum SBSystemPreferencesEnum SBSystemPreferencesEnum;



/*
 * Standard Suite
 */

// A scriptable object.
@interface SBSystemPreferencesItem : SBObject

@property (copy) NSDictionary *properties;  // All of the object's properties.

- (void) closeSaving:(SBSystemPreferencesSavo)saving savingIn:(NSURL *)savingIn;  // Close an object.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy object(s) and put the copies at a new location.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move object(s) to a new location.
- (void) saveAs:(NSString *)as in:(NSURL *)in_;  // Save an object.

@end

// An application's top level scripting object.
@interface SBSystemPreferencesApplication : SBApplication

- (SBElementArray *) documents;
- (SBElementArray *) windows;

@property (readonly) BOOL frontmost;  // Is this the frontmost (active) application?
@property (copy, readonly) NSString *name;  // The name of the application.
@property (copy, readonly) NSString *version;  // The version of the application.

- (SBSystemPreferencesDocument *) open:(NSURL *)x;  // Open an object.
- (void) print:(NSURL *)x printDialog:(BOOL)printDialog withProperties:(SBSystemPreferencesPrintSettings *)withProperties;  // Print an object.
- (void) quitSaving:(SBSystemPreferencesSavo)saving;  // Quit an application.

@end

// A color.
@interface SBSystemPreferencesColor : SBSystemPreferencesItem


@end

// A document.
@interface SBSystemPreferencesDocument : SBSystemPreferencesItem

@property (readonly) BOOL modified;  // Has the document been modified since the last save?
@property (copy) NSString *name;  // The document's name.
@property (copy) NSString *path;  // The document's path.


@end

// A window.
@interface SBSystemPreferencesWindow : SBSystemPreferencesItem

@property NSRect bounds;  // The bounding rectangle of the window.
@property (readonly) BOOL closeable;  // Whether the window has a close box.
@property (copy, readonly) SBSystemPreferencesDocument *document;  // The document whose contents are being displayed in the window.
@property (readonly) BOOL floating;  // Whether the window floats.
- (NSInteger) id;  // The unique identifier of the window.
@property NSInteger index;  // The index of the window, ordered front to back.
@property (readonly) BOOL miniaturizable;  // Whether the window can be miniaturized.
@property BOOL miniaturized;  // Whether the window is currently miniaturized.
@property (readonly) BOOL modal;  // Whether the window is the application's current modal window.
@property (copy) NSString *name;  // The full title of the window.
@property (readonly) BOOL resizable;  // Whether the window can be resized.
@property (readonly) BOOL titled;  // Whether the window has a title bar.
@property BOOL visible;  // Whether the window is currently visible.
@property (readonly) BOOL zoomable;  // Whether the window can be zoomed.
@property BOOL zoomed;  // Whether the window is currently zoomed.


@end



/*
 * Text Suite
 */

// This subdivides the text into chunks that all have the same attributes.
@interface SBSystemPreferencesAttributeRun : SBSystemPreferencesItem

- (SBElementArray *) attachments;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@property (copy) NSColor *color;  // The color of the first character.
@property (copy) NSString *font;  // The name of the font of the first character.
@property NSInteger size;  // The size in points of the first character.


@end

// This subdivides the text into characters.
@interface SBSystemPreferencesCharacter : SBSystemPreferencesItem

- (SBElementArray *) attachments;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@property (copy) NSColor *color;  // The color of the first character.
@property (copy) NSString *font;  // The name of the font of the first character.
@property NSInteger size;  // The size in points of the first character.


@end

// This subdivides the text into paragraphs.
@interface SBSystemPreferencesParagraph : SBSystemPreferencesItem

- (SBElementArray *) attachments;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@property (copy) NSColor *color;  // The color of the first character.
@property (copy) NSString *font;  // The name of the font of the first character.
@property NSInteger size;  // The size in points of the first character.


@end

// Rich (styled) text
@interface SBSystemPreferencesText : SBSystemPreferencesItem

- (SBElementArray *) attachments;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@property (copy) NSColor *color;  // The color of the first character.
@property (copy) NSString *font;  // The name of the font of the first character.
@property NSInteger size;  // The size in points of the first character.


@end

// Represents an inline text attachment.  This class is used mainly for make commands.
@interface SBSystemPreferencesAttachment : SBSystemPreferencesText

@property (copy) NSString *fileName;  // The path to the file for the attachment


@end

// This subdivides the text into words.
@interface SBSystemPreferencesWord : SBSystemPreferencesItem

- (SBElementArray *) attachments;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@property (copy) NSColor *color;  // The color of the first character.
@property (copy) NSString *font;  // The name of the font of the first character.
@property NSInteger size;  // The size in points of the first character.


@end



/*
 * System Preferences
 */

// an anchor within a preference pane
@interface SBSystemPreferencesAnchor : SBSystemPreferencesItem

@property (copy, readonly) NSString *name;  // name of the anchor within a preference pane

- (SBSystemPreferencesAnchor *) reveal;  // Reveals an anchor within a preference pane or preference pane itself

@end

// System Preferences top level scripting object
@interface SBSystemPreferencesApplication (SystemPreferences)

- (SBElementArray *) panes;

@property (copy) SBSystemPreferencesPane *currentPane;  // the currently selected pane
@property (copy, readonly) SBSystemPreferencesWindow *preferencesWindow;  // the main preferences window
@property BOOL showAll;  // Is SystemPrefs in show all view. (Setting to false will do nothing)

@end

// a preference pane
@interface SBSystemPreferencesPane : SBSystemPreferencesItem

- (SBElementArray *) anchors;

- (NSString *) id;  // locale independent name of the preference pane; can refer to a pane using the expression: pane id "<name>"
@property (copy, readonly) NSString *localizedName;  // localized name of the preference pane
@property (copy, readonly) NSString *name;  // name of the preference pane as it appears in the title bar; can refer to a pane using the expression: pane "<name>"

- (double) timedLoad;  // Times and loads given preference pane and returns load time.

@end



/*
 * Type Definitions
 */

@interface SBSystemPreferencesPrintSettings : SBObject

@property NSInteger copies;  // the number of copies of a document to be printed
@property BOOL collating;  // Should printed copies be collated?
@property NSInteger startingPage;  // the first page of the document to be printed
@property NSInteger endingPage;  // the last page of the document to be printed
@property NSInteger pagesAcross;  // number of logical pages laid across a physical page
@property NSInteger pagesDown;  // number of logical pages laid out down a physical page
@property (copy) NSDate *requestedPrintTime;  // the time at which the desktop printer should print the document
@property SBSystemPreferencesEnum errorHandling;  // how errors are handled
@property (copy) NSString *faxNumber;  // for fax number
@property (copy) NSString *targetPrinter;  // for target printer

- (void) closeSaving:(SBSystemPreferencesSavo)saving savingIn:(NSURL *)savingIn;  // Close an object.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy object(s) and put the copies at a new location.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move object(s) to a new location.
- (void) saveAs:(NSString *)as in:(NSURL *)in_;  // Save an object.

@end

