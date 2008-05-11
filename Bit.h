//
//  Bit.h
//  Multitouch
//
//  Created by Bridger Maxwell on 12/30/07.
//  Copyright 2007 Fiery Ferret. All rights reserved.
//
//

#import <Quartz/Quartz.h>
#import <TUIO/TuioClient.h> 

@interface Bit : CALayer <NSCopying, TuioCursorListener>
{
	NSMutableArray* _tuioCursors;
	BOOL _cursorsUpdated;
	
	double _originalRotationOffset;
	CGPoint _positionOffset;
	CGFloat _scaleMultiplier;
}

@property CGFloat scale;
@property double rotation;
- (void) setRotation: (double)rotation aboutPoint:(CGPoint)rotationCenter;

- (id) init;
- (CGPoint) desiredPosition;
- (double) desiredRotation;
- (CGFloat) desiredScale;

- (void) tuioCursorAdded: (TuioCursor*) newCursor;
- (void) tuioCursorUpdated: (TuioCursor*) updatedCursor;
- (void) tuioCursorRemoved: (TuioCursor*) deadCursor;
- (void) tuioCursorFrameFinished;

- (CGFloat) distanceBetweenPoints:(CGPoint)point1 point2:(CGPoint)point2;
- (double) angleBetweenPoints:(CGPoint)point1 point2:(CGPoint)point2;

@end
