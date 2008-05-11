//
//  BoardView.m
//  Multitouch
//
//  Created by Bridger Maxwell on 12/30/07.
//  Copyright 2007 Fiery Ferret. All rights reserved.
// 

#import "BoardView.h" 
#import <QTKit/QTKit.h>
#import "QuartzUtils.h"

NSString* const sMyTestDatabasePath	= @"~/Pictures/xkcd Comics/xkcdDB.sqlite";
NSString* const sComicFolder	= @"~/Pictures/xkcd Comics/";
const CGFloat maxComicSize = 300;

@implementation BoardView

@synthesize corkBoard=_corkBoardLayer;
@synthesize bits = _bits;

- (IBAction) enterFullScreen: (id)sender
{
    if( self.isInFullScreenMode ) {
        [self exitFullScreenModeWithOptions: nil];
    } else {
		NSNumber* shouldGoFullScreen = [NSNumber numberWithBool:false];
		NSDictionary* options = [[NSDictionary alloc] initWithObjectsAndKeys:shouldGoFullScreen , NSFullScreenModeAllScreens, nil];
        [self enterFullScreenMode: self.window.screen 
                      withOptions: options];
    }
}

- (void) awakeFromNib { 

    [self registerForDraggedTypes: [NSImage imagePasteboardTypes]];
	[self registerForDraggedTypes: [NSArray arrayWithObjects: NSFilenamesPboardType, NSPDFPboardType, nil]];
		
	_tuioClient = [[TuioClient alloc] initWithPortNumber:3333];
	[self setupLayers];
	[_tuioClient setTuioCursorDelegate:self];
}

- (void) setupLayers {
    _corkBoardLayer = [[CALayer alloc] init];
	_corkBoardLayer.frame = [self corkBoardFrame];
    _corkBoardLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
    [self.layer addSublayer: _corkBoardLayer];
	
	_bits = [NSMutableArray array];
	_cursorRelationships = [[NSMutableDictionary alloc] init];
	_comics = [[NSMutableDictionary alloc] init];
	
	_searchField = [[CATextLayer alloc] init];
	_searchField.string=@"";
	_searchField.font=@"Lucida-Grande";
	_searchField.fontSize=60;
	_searchField.alignmentMode = kCAAlignmentCenter;
	CGColorRef whiteColor = CGColorCreateGenericGray(1.0,1.0);
	_searchField.foregroundColor=whiteColor;
	const int height = 75;
	_searchField.bounds=CGRectMake(0.0,0.0,_corkBoardLayer.bounds.size.width / 2,height);
	_searchField.borderWidth=2.0;
	_searchField.borderColor=whiteColor;
	CGColorRelease(whiteColor);
	_searchField.cornerRadius=height/2;
	
//	CIFilter *filter = [CIFilter filterWithName:@"CIBloom"];
//	[filter setDefaults];
//	[filter setValue:[NSNumber numberWithFloat:5.0] forKey:@"inputRadius"];
//	[filter setName:@"pulseFilter"];
//	[_searchField setFilters:[NSArray arrayWithObject:filter]];
//	
//	CABasicAnimation* pulseAnimation = [CABasicAnimation animation];
//	pulseAnimation.keyPath = @"filters.pulseFilter.inputIntensity";
//	pulseAnimation.fromValue = [NSNumber numberWithFloat: 0.0];
//	pulseAnimation.toValue = [NSNumber numberWithFloat: 0.8];
//	pulseAnimation.duration = 1.0;
//	pulseAnimation.repeatCount = 1e100f;
//	pulseAnimation.autoreverses = YES;
//	pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:
//									 kCAMediaTimingFunctionEaseInEaseOut];
//	[_searchField addAnimation:pulseAnimation forKey:nil];
	
	[_corkBoardLayer addSublayer:_searchField]; 
	_searchField.position = CGPointMake([_corkBoardLayer position].x, height) ;
	_searchField.autoresizingMask = kCALayerWidthSizable | kCALayerMinXMargin | kCALayerMaxXMargin;
	
	NSString* path = [sMyTestDatabasePath stringByExpandingTildeInPath];		
	_db = [QuickLiteDatabase databaseWithFile:path];
	if ([_db open]) {//:YES cacheMethod:DoNotCacheData exposeSQLOnNotify:NO debugMode:NO]) {
	} else {
		NSLog(@"Trouble when opening the data file. Make sure the path is valid.");
	}
}

- (void)drawRect:(NSRect)rect
{
	CGColorRef black = CGColorGetConstantColor(kCGColorBlack);
	
    self.layer.backgroundColor = black;
	
    // draw a basic gradient for the view background
    NSColor* gradientTop    = [NSColor colorWithCalibratedWhite:0.35 alpha:1.0];
    NSColor* gradientBottom = [NSColor colorWithCalibratedWhite:0.02 alpha:1.0];
	NSGradient* gradient = [[NSGradient alloc] initWithStartingColor:gradientBottom
                                                         endingColor:gradientTop];
	NSPoint topMiddle    = NSMakePoint( CGRectGetMidX(self.layer.bounds), CGRectGetMaxY(self.layer.bounds));
	NSPoint bottomMiddle = NSMakePoint( CGRectGetMidX(self.layer.bounds), CGRectGetMidY(self.layer.bounds));
	CGFloat width = CGRectGetWidth(self.layer.bounds);
	[gradient drawFromCenter:bottomMiddle radius: (width / 2)
					toCenter:topMiddle radius:0 
					 options: NSGradientDrawsBeforeStartingLocation ];
}

- (CGRect) corkBoardFrame
{
    return self.layer.bounds;
}


- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pb = [sender draggingPasteboard];
    if( [NSImage canInitWithPasteboard: pb] || [QTMovie canInitWithPasteboard: pb])
        return NSDragOperationCopy;
    else
        return NSDragOperationNone;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{

	CGImageRef image = GetCGImageFromPasteboard([sender draggingPasteboard]);
    if( image ) {
        return YES;
    } else {
		//If there was no image check for a pdf
		CGPDFDocumentRef pdf = GetCGPDFFromPasteboard([sender draggingPasteboard]);
		if ( pdf ) {
			return YES;
		} else {
			//If there was no image check for a pdf
			QTMovie *movie = GetQTMovieFromPasteboard([sender draggingPasteboard]);
			if ( movie ) {
				return YES;
			} else {
				return NO;
			}
		}
	}
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSPoint mousePos = [[self window] mouseLocationOutsideOfEventStream];
	mousePos = [self convertPoint: mousePos fromView:nil]; //Convert the point from the window to this view
	
	CGPoint pos = CGPointMake(mousePos.x, mousePos.y);
	pos = [self.layer convertPoint:pos toLayer:_corkBoardLayer]; //Convert the point from this view to the corkBoardLayer
		
	
    CGImageRef image = GetCGImageFromPasteboard([sender draggingPasteboard]);
    if( image ) {
		[self addPhoto: image
			  position: pos];
        return YES;
    } else {
		//If there was no image check for a pdf
		QTMovie* movie = GetQTMovieFromPasteboard([sender draggingPasteboard]);
		if ( movie ) {
			[self addClip: movie
				 position: pos];
			return YES;
		} else {
			//If there was no image check for a pdf
			CGPDFDocumentRef pdf = GetCGPDFFromPasteboard([sender draggingPasteboard]);
			if ( pdf ) {
				[self addDocument: pdf
						 position: pos];
				return YES;
			} else {
				return NO;
			}
		}
	}
}

- (IBAction) resetCorkBoard: (id)sender {
	_corkBoardLayer.frame = self.layer.bounds;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)keyDown:(NSEvent *)theEvent {
    [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
}





- (void)insertText:(id)string {
	_searchField.string = [_searchField.string stringByAppendingString:string];
	[self showComicsMatchingString:_searchField.string];
}

- (void)deleteBackward:(id)sender {
	if ([_searchField.string length] > 0){
		_searchField.string = [_searchField.string substringWithRange:NSMakeRange(0,[_searchField.string length] -1)];
		[self showComicsMatchingString:_searchField.string];
	} 
}


- (void) showComicsMatchingString:(NSString *)searchTerms {
	NSMutableArray* aliveComics = [[NSMutableArray alloc] init];
	if (![searchTerms isEqualToString:@""]) {
		searchTerms = [[@"%" stringByAppendingString:searchTerms] stringByAppendingString:@"%"];
		NSString* query = [NSString stringWithFormat:
						   [@"SELECT * FROM xkcd_comics WHERE (transcript LIKE '%@' OR tags LIKE '%@' OR name LIKE '%@' OR number LIKE '%@'"
							stringByAppendingString:@"OR altText LIKE '%@') AND (NOT (tags LIKE '%%profanity%%')) ORDER BY number DESC LIMIT 0, 20"]
						   ,searchTerms,searchTerms,searchTerms,searchTerms,searchTerms];
		QuickLiteCursor* cur = [_db performQuery:query];
		
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue  
						 forKey:kCATransactionDisableActions];	
		unsigned int counter;
		for (counter = 1; counter <= [cur rowCount]; counter++) {
			unsigned int countDown = [cur rowCount] - counter;
			QuickLiteRow* row = [cur rowAtIndex:countDown];
			NSString* comicNumberString = [row stringForColumn:@"xkcd_comics.number"];
			int comicNumber = [comicNumberString intValue];		
			NSNumber* key = [NSNumber numberWithInt:comicNumber];
			[aliveComics addObject:key];
			CBComic* existing = [_comics objectForKey:key];
			if (!existing){
				ComicRef newComic = [self comicRefWithNumber:comicNumber];
				[self addComic:newComic position:CGPointMake(30,30) ];
			}
		}
		[CATransaction commit];
		
	}
	
	[CATransaction begin];
	//	[CATransaction setValue:[NSNumber numberWithFloat:2.0]
	//					 forKey:kCATransactionAnimationDuration];	
	unsigned int counter = 0;
	for (NSNumber* comicNumber in [_comics allKeys]) {
		if (![aliveComics containsObject:comicNumber]) {
			CBComic* toDelete = [_comics objectForKey:comicNumber];
			if (toDelete) {
				[toDelete removeFromSuperlayer];
				[_comics removeObjectForKey:comicNumber];
			}
		} else {
			CGPoint comicPosition = [self comicPosition:counter];
			CBComic* toUpdate = [_comics objectForKey:comicNumber];
			toUpdate.position = comicPosition;
			counter++;
		}
	}
	[CATransaction commit];
	
}

- (CGPoint) comicPosition: (unsigned int) num { 
	float comicsPerRow = floor(_corkBoardLayer.bounds.size.width / maxComicSize);
	float comicsPerColumn = floor(( _corkBoardLayer.bounds.size.height - 100) / maxComicSize);
	int column = fmod(num, comicsPerRow) + 1;
	int row = fmod(floor( num / comicsPerRow) + 1,comicsPerColumn) + 1;
	float vWidth =  _corkBoardLayer.bounds.size.width / (comicsPerRow * 2);
	float xCord = vWidth + (column - 1) * vWidth * 2;
	float vHeight = (_corkBoardLayer.bounds.size.height - 100) / (comicsPerColumn * 2);
	float yCord = _corkBoardLayer.bounds.size.height - (vHeight + (row - 1) * vHeight * 2);
	return CGPointMake(xCord, yCord);
}

- (void) addPhoto: (CGImageRef)image position: (CGPoint)pos
{
	CGFloat maxDimensions = 300.0;
	int width = CGImageGetWidth(image), height = CGImageGetHeight(image);
	maxDimensions /= MAX(width,height);             // interpret scale as target dimensions
	width = MIN(width,ceil( width * maxDimensions));
	height= MIN(height,ceil( height * maxDimensions));
	CGRect rect = CGRectMake(0,0,width,height);
	
	rect = [_corkBoardLayer convertRect:rect fromLayer:_corkBoardLayer.superlayer];
	
	CBPhoto * newPhoto = [[CBPhoto alloc] initWithImage: image
												 bounds: rect
											   position: pos];
	[_bits addObject: newPhoto];
	[_corkBoardLayer addSublayer: newPhoto];
}

- (void) addDocument: (CGPDFDocumentRef)pdf position: (CGPoint)pos
{
	CGRect rect = CGRectMake(0,0,300,300);
	
	rect = [_corkBoardLayer convertRect:rect fromLayer:_corkBoardLayer.superlayer];
	
	CBDocument * newDocument = [[CBDocument alloc] initWithPDF: pdf
														bounds: rect
													  position: pos];
	[_bits addObject: newDocument];
	[_corkBoardLayer addSublayer: newDocument];
}

- (void) addClip: (QTMovie*)movie position: (CGPoint)pos
{
	CGFloat maxDimensions = 300.0;
	NSValue *value = [movie attributeForKey:QTMovieNaturalSizeAttribute];
	NSSize size = [value sizeValue]; 
	float width = size.width;
	float height = size.height;
	maxDimensions /= MAX(width,height);             // interpret scale as target dimensions
	width = MIN(width,ceil( width * maxDimensions));
	height= MIN(height,ceil(height * maxDimensions));
	CGRect rect = CGRectMake(0,0,width,height);
	
	rect = [_corkBoardLayer convertRect:rect fromLayer:_corkBoardLayer.superlayer];
	
	CBClip * newClip = [[CBClip alloc] initWithMovie: movie
											  bounds: rect
											position: pos];
	[_bits addObject: newClip];
	[_corkBoardLayer addSublayer: newClip];
}

- (void) addComic: (ComicRef)comic position: (CGPoint)pos
{
	int width = CGImageGetWidth(comic.image), height = CGImageGetHeight(comic.image);
	CGFloat maxDimensions = maxComicSize / MAX(width,height);             // interpret scale as target dimensions
	width = MIN(width,ceil( width * maxDimensions));
	height= MIN(height,ceil( height * maxDimensions));
	CGRect rect = CGRectMake(0,0,width,height);
	
	rect = [_corkBoardLayer convertRect:rect fromLayer:_corkBoardLayer.superlayer];
	
	CBComic * newComic = [[CBComic alloc] initWithComic: comic
												 bounds: rect
											   position: pos];
	
	[_comics setObject:newComic forKey:[NSNumber numberWithInt:comic.number]];
	[_corkBoardLayer addSublayer: newComic];
}

- (void) tuioCursorAdded: (TuioCursor*) newCursor{
	CGPoint where =[self convertPointToBoardLayer:NSPointFromCGPoint([newCursor position])];
	CALayer *layer = [[self layer] hitTest: where];
    while( layer ) {
        if( [layer conformsToProtocol:@protocol(TuioCursorListener)]) {
			where = [[layer superlayer] convertPoint:where fromLayer:_corkBoardLayer];
			[newCursor setPosition:where];
			[(Bit *)layer tuioCursorAdded:newCursor];
			[_cursorRelationships setObject:layer forKey:[NSNumber numberWithUnsignedInt:[newCursor uniqueID]]];
			
			
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue  
							 forKey:kCATransactionDisableActions];
			[[layer superlayer] insertSublayer:layer above:[[[layer superlayer] sublayers]  
															lastObject]];
			[CATransaction commit];
			
			break;
        } else
            layer = layer.superlayer;
    }
}

- (void) tuioCursorUpdated: (TuioCursor*) updatedCursor{
	
	id layerToUpdate = [_cursorRelationships objectForKey:[NSNumber numberWithUnsignedInt:[updatedCursor uniqueID]]];
	if (layerToUpdate) {
		//Update the positions to reflect those of the receiving layer
		CGPoint where =[self convertPointToBoardLayer:NSPointFromCGPoint([updatedCursor position])];
		where = [[layerToUpdate superlayer] convertPoint:where fromLayer:_corkBoardLayer];
		[updatedCursor setPosition:where];
		[layerToUpdate tuioCursorUpdated:updatedCursor];
	}
}

- (void) tuioCursorRemoved: (TuioCursor*) deadCursor{
	NSNumber* key = [NSNumber numberWithUnsignedInt:[deadCursor uniqueID]];
	id layerToUpdate = [_cursorRelationships objectForKey:key];
	if (layerToUpdate) {
		//Update the positions to reflect those of the receiving layer
		CGPoint where =[self convertPointToBoardLayer:NSPointFromCGPoint([deadCursor position])];
		where = [[layerToUpdate superlayer] convertPoint:where fromLayer:_corkBoardLayer];
		[deadCursor setPosition:where];
		[layerToUpdate tuioCursorRemoved:deadCursor];
		[_cursorRelationships removeObjectForKey:key];
	}
}

- (void) tuioCursorFrameFinished{
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue  
					 forKey:kCATransactionDisableActions]; //This disables the animations, to make it less intensive
	for (TuioCursor* key in _cursorRelationships) {
		[[_cursorRelationships objectForKey:key] tuioCursorFrameFinished];
	}
	[CATransaction commit];
}

- (CGPoint) convertPointToBoardLayer:(NSPoint) windowPoint {
	windowPoint = [[self window] convertScreenToBase:windowPoint]; //Now it is in window coordinates
	CGPoint where = NSPointToCGPoint([self convertPoint: windowPoint fromView: nil]); //Now it is in the view's coordinates
    //where = [_corkBoardLayer convertPoint:where fromLayer:[_self layer]];
	return where;
}

- (ComicRef) comicRefWithNumber:(int) comicNum {
	ComicRef comic; 
	QuickLiteRow* row = [[_db performQuery:[NSString stringWithFormat:@"SELECT name,altText,tags,filename FROM xkcd_comics WHERE number = %d;",comicNum]]rowAtIndex:0];
	NSString* name = [row stringForColumn:@"xkcd_comics.name"];
	if (name) {
		NSString* titleText = [row stringForColumn:@"xkcd_comics.altText"];
		NSString* tagString = [row stringForColumn:@"xkcd_comics.tags"];
		NSString* filename = [row stringForColumn:@"xkcd_comics.filename"];
		
		NSArray* tags = [tagString componentsSeparatedByString:@","];
		
		filename = [[sComicFolder stringByAppendingString:filename] stringByExpandingTildeInPath];
		CGImageRef image = CreateCGImageFromFile(filename);
		
		comic.image = image;
		comic.number = comicNum;
		comic.name = name;
		comic.titleText = titleText;
		comic.tags = tags;
		
		CGImageRelease(image);
		
		return comic;
	} else {
		comic.name = @"";
		return comic;
	}
}


@end
