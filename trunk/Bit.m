//
//  Bit.m
//  Multitouch
//
//  Created by Bridger Maxwell on 12/30/07.
//  Copyright 2007 Fiery Ferret. All rights reserved.
//

#import "Bit.h"
#import "QuartzUtils.h"

/**  WARNING: THIS CODE REQUIRES GARBAGE COLLECTION!
 **  This sample application uses Objective-C 2.0 garbage collection.
 **  Therefore, the source code in this file does NOT perform manual object memory management.
 **  If you reuse any of this code in a process that isn't garbage collected, you will need to
 **  add all necessary retain/release/autorelease calls, and implement -dealloc methods,
 **  otherwise unpleasant leakage will occur!
 **/

@implementation Bit
const float MaxLayerSize = 1750; 


- (id) init
{
    self = [super init];
    if (self != nil) {
		_tuioCursors = [NSMutableArray array];
    }
    return self;
}

- (id) copyWithZone: (NSZone*)zone
{
    // NSLayer isn't copyable, but it is archivable. So create a copy by archiving to
    // a temporary data block, then unarchiving a new layer from that block.
    // One complication is that, due to a bug in Core Animation, CALayer can't archive
    // a pattern-based CGColor. So as a workaround, clear the background before archiving,
    // then restore it afterwards.
    CGColorRef bg = CGColorRetain(self.backgroundColor);
    self.backgroundColor = NULL;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: self];
    self.backgroundColor = bg;
    Bit *clone = [NSKeyedUnarchiver unarchiveObjectWithData: data];
    clone.backgroundColor = bg;
    CGColorRelease(bg);

    return clone;
}

- (CGPoint) desiredPosition {
	//newLayerPosition = newCursorPosition + oldLayerPosition - oldCursorPosition
	//_positionOffset already = (oldLayerPosition - oldCursorPosition)
	CGPoint newPosition = [self position];
	if ([_tuioCursors count] == 1) {
		TuioCursor* actingCursor = [_tuioCursors objectAtIndex:0];
		CGPoint newCursorPosition = [actingCursor position];
		newPosition = CGPointMake((newCursorPosition.x + _positionOffset.x),
								  (newCursorPosition.y + _positionOffset.y));
	} else if ([_tuioCursors count] > 1) {
		//We do the same as the last one, but using the midpoints of the cursor points
		TuioCursor* actingCursor1 = [_tuioCursors objectAtIndex:0];
		TuioCursor* actingCursor2 = [_tuioCursors objectAtIndex:1];
		CGPoint newCursorPosition1 = [actingCursor1 position];
		CGPoint newCursorPosition2 = [actingCursor2 position];
		CGPoint newMidpoint = CGPointMake( ((newCursorPosition1.x + newCursorPosition2.x) / 2),
										   ((newCursorPosition1.y + newCursorPosition2.y) / 2) );
		newPosition = CGPointMake((newMidpoint.x + _positionOffset.x),
								  (newMidpoint.y + _positionOffset.x));	
	}
	return newPosition;
}
- (double) desiredRotation {
	//newLayerRotation = newCursorAngle + oldLayerRotation - oldCursorAngle
	//_originalRotationOffset already = (oldLayerRotation - oldCursorAngle)
	double newRotation = [self rotation];
	if ([_tuioCursors count] > 1) {
		TuioCursor* actingCursor1 = [_tuioCursors objectAtIndex:0];
		TuioCursor* actingCursor2 = [_tuioCursors objectAtIndex:1];
		double newCursorAngle = [self angleBetweenPoints:[actingCursor1 position] point2:[actingCursor2 position]];
		return (newCursorAngle + _originalRotationOffset);		
	}
	return newRotation;	
}

- (double) angleBetweenPoints:(CGPoint)point1 point2:(CGPoint)point2 {
	return atan2(point2.y - point1.y,point2.x - point1.x);
}


- (CGFloat) desiredScale{
	//newLayerScale = newCursorDistance * oldLayerScale / oldCursorDistance
	//_scaleMultiplier already equals (oldLayerScale / oldCursorDistance)
	CGFloat newScale = [self scale];
	if ([_tuioCursors count] > 1) {
		TuioCursor* actingCursor1 = [_tuioCursors objectAtIndex:0];
		TuioCursor* actingCursor2 = [_tuioCursors objectAtIndex:1];
		CGFloat newCursorDistance = [self distanceBetweenPoints:[actingCursor1 position] point2:[actingCursor2 position]];
		newScale = (_scaleMultiplier * newCursorDistance);
		if (self.bounds.size.width * newScale > MaxLayerSize ) {
			newScale = MaxLayerSize / self.bounds.size.width;
		}
	}
	return newScale;
}

- (CGFloat) distanceBetweenPoints:(CGPoint)point1 point2:(CGPoint)point2 {
	return sqrt(pow((point1.x - point2.x),2) + pow((point1.y - point2.y),2));
}


- (CGFloat) scale
{
    NSNumber *scale = [self valueForKeyPath: @"transform.scale"];
    return scale.floatValue;
}

- (void) setScale: (CGFloat)scale
{
    [self setValue: [NSNumber numberWithFloat: scale]
        forKeyPath: @"transform.scale"];
}

- (double) rotation
{
    NSNumber *rot = [self valueForKeyPath: @"transform.rotation"];
    return rot.doubleValue;
}

- (void) setRotation: (double)rotation
{
    [self setValue: [NSNumber numberWithDouble: rotation]
        forKeyPath: @"transform.rotation"];
}

- (void) setRotation: (double)rotation aboutPoint:(CGPoint)rotationCenter
{
    [self setValue: [NSNumber numberWithDouble: rotation]
        forKeyPath: @"transform.rotation"];
}

- (void) tuioCursorAdded: (TuioCursor*) newCursor{
	[_tuioCursors addObject:newCursor];
	
	if ([_tuioCursors count] == 1) {
		//newLayerPosition = newCursorPosition + oldLayerPosition - oldCursorPosition
		//We figure and store (oldLayerPosition - oldCursorPosition) to later find the newLayerPosition
		TuioCursor* actingCursor = [_tuioCursors objectAtIndex:0];
		_positionOffset = CGPointMake([self position].x - [actingCursor position].x,
									  [self position].y - [actingCursor position].y);

	} else if ([_tuioCursors count] == 2) {
		//We store the same information here as above, but using the midpoint of the two cursors
		TuioCursor* actingCursor1 = [_tuioCursors objectAtIndex:0];
		TuioCursor* actingCursor2 = [_tuioCursors objectAtIndex:1];
		CGPoint originalMidpoint = CGPointMake((([actingCursor1 position].x + [actingCursor2 position].x) / 2),
											   (([actingCursor1 position].y + [actingCursor2 position].y) / 2) );
		_positionOffset = CGPointMake([self position].x - originalMidpoint.x,
									  [self position].y - originalMidpoint.y);
		
		//newLayerScale = newCursorDistance * oldCursorDistance / oldLayerScale
		//We figure and store (oldCursorDistance / oldLayerScale) to later find the newLayerScale
		CGFloat originalCursorDistance = [self distanceBetweenPoints:[actingCursor1 position] point2:[actingCursor2 position]];
		NSLog(@"original distance: %f",originalCursorDistance);
		_scaleMultiplier = [self scale] / originalCursorDistance;
		
		
		//newLayerRotation = newCursorAngle + oldLayerRotation - oldCursorAngle
		//We figure and store (oldLayerRotation - oldCursorAngle) to later find the newLayerRotation
		double originalCursorRotation = [self angleBetweenPoints:[actingCursor1 position] point2:[actingCursor2 position]];
		_originalRotationOffset = [self rotation] - originalCursorRotation;
	}
}

- (void) tuioCursorUpdated: (TuioCursor*) updatedCursor{
	NSUInteger index = [_tuioCursors indexOfObject:updatedCursor];
	_cursorsUpdated = _cursorsUpdated || ((index != NSNotFound) && (index <= 2));
}

- (void) tuioCursorRemoved: (TuioCursor*) deadCursor{
	[_tuioCursors removeObject:deadCursor];
	if ([_tuioCursors count] == 1) {
		//We figure and store (oldLayerPosition - oldCursorPosition) again, now that there was only one cursor
		TuioCursor* actingCursor = [_tuioCursors objectAtIndex:0];
		_positionOffset = CGPointMake([self position].x - [actingCursor position].x,
									  [self position].y - [actingCursor position].y);
	}
}

- (void) tuioCursorFrameFinished{
	if (_cursorsUpdated) {
		_cursorsUpdated = NO;
		[self setPosition:[self desiredPosition]];
		[self setScale:[self desiredScale]];
		[self setRotation:[self desiredRotation]];
	}
}

@end
