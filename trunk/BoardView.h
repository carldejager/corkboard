//
//  BoardView.h
//  Multitouch
// 
//  Created by Bridger Maxwell on 12/30/07.
//  Copyright 2007 Fiery Ferret. All rights reserved.
//

#import "CBPhoto.h" 
#import <bit.h>
#import <TUIO/TuioClient.h>  
#import "CBPhoto.h"
#import "CBDocument.h" 
#import "CBClip.h"
#import "CBComic.h"
#import <QuickLite/QuickLiteGlobals.h>
#import <QuickLite/QuickLiteCursor.h>
#import <QuickLite/QuickLiteRow.h>
#import <QuickLite/QuickLiteDatabaseExtras.h>
#import <QuickLite/sqliteInt.h>

@interface BoardView : NSView <TuioCursorListener> {
	IBOutlet id scaleLabel;
    @private
    CALayer *_corkBoardLayer;                        // main layer
	TuioClient *_tuioClient;
	
	CATextLayer *_searchField;
    //CALayer *_board;
	NSMutableArray *_bits;
	NSMutableDictionary *_cursorRelationships;
	//NSView* _outerView;
	QuickLiteDatabase* _db;
	NSMutableDictionary* _comics;
}

@property (readonly) CALayer *corkBoard;

- (CGRect) corkBoardFrame;
- (void) setupLayers;
- (IBAction) enterFullScreen: (id)sender;
- (IBAction) resetCorkBoard: (id)sender;
- (void)keyDown:(NSEvent *)theEvent;
- (void)insertText:(id)string;
- (void)deleteBackward:(id)sender;
- (BOOL)acceptsFirstResponder;

- (void) addPhoto: (CGImageRef)image position: (CGPoint)pos;
- (void) addDocument: (CGPDFDocumentRef)pdf position: (CGPoint)pos;
- (void) addClip: (QTMovie*)movie position: (CGPoint)pos;
- (void) addComic: (ComicRef)comic position: (CGPoint)pos;
- (CGPoint) convertPointToBoardLayer:(NSPoint) windowPoint;
- (void) showComicsMatchingString:(NSString *)searchTerms;
@property (readonly) NSArray *bits;
- (ComicRef) comicRefWithNumber:(int) comicNum;
- (CGPoint) comicPosition: (unsigned int) num;
- (void)insertText:(id)string;
- (void)deleteBackward:(id)sender;


#pragma mark -
#pragma mark TUIO Cursor Messages:

- (void) tuioCursorAdded: (TuioCursor*) newCursor;
- (void) tuioCursorUpdated: (TuioCursor*) updatedCursor;
- (void) tuioCursorRemoved: (TuioCursor*) deadCursor;
- (void) tuioCursorFrameFinished;

@end
