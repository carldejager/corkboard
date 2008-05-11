//
//  CBClip.m
//  Multitouch
//
//  Created by Bridger Maxwell on 1/15/08.
//  Copyright 2008 Fiery Ferret. All rights reserved.
//

#import "CBClip.h"


@implementation CBClip

- (id) initWithMovie: (QTMovie*)movie bounds: (CGRect)rect position: (CGPoint)pos {
    self = [super init];
    if (self != nil) {
		self.position = pos;
        [self setMovie: movie bounds: rect];
    }
    return self;
}

- (void) setMovie: (QTMovie*)movie bounds: (CGRect)rect {

	self.bounds = rect;
	CGFloat border = MAX(CGRectGetHeight(rect),CGRectGetWidth(rect));
	border /= 60;
//	CGColorRef background =  CGColorGetConstantColor(kCGColorBlack);
//	background = CGColorCreateCopyWithAlpha(background,0.8);
//	self.backgroundColor = background;

    mQTMovie = movie;
	if (mQTMovie)
	{
		// create our movie layer
		innerMovie = [QTMovieLayer layerWithMovie:mQTMovie];
				[self addSublayer:innerMovie];

		// size the layer
		innerMovie.contentsGravity = @"resize";
		innerMovie.bounds = CGRectInset(rect,border, border);
		CGPoint innerPos = CGPointMake( CGRectGetMidX(rect), CGRectGetMidY(rect));
		innerMovie.position = innerPos;		
		// center it on the mContainer
		innerMovie.position = innerPos;
		
		[mQTMovie setMuted:YES];
		[mQTMovie setAttribute:@"YES" forKey:QTMovieLoopsAttribute];
		[mQTMovie play];
	}
	
	self.borderWidth = border;
	self.borderColor = CGColorGetConstantColor(kCGColorWhite);
	///self.shadowOpacity = 1.0; This is the source of all slowness and woe
} 

@end
