//
//  CBPhoto.m
//  Multitouch
//
//  Created by Bridger Maxwell on 1/5/08.
//  Copyright 2008 Fiery Ferret. All rights reserved.
//

#import "CBPhoto.h"
#import "QuartzUtils.h"


@implementation CBPhoto

- (id) initWithImage: (CGImageRef)image bounds: (CGRect)rect position: (CGPoint)pos
{
    self = [super init];
    if (self != nil) {
		self.position = pos;
        [self setImage: image bounds: rect];
    }
    return self;
}

- (void) setImage: (CGImageRef)image bounds: (CGRect)rect
{
	self.bounds = rect;
	CGFloat border = MAX(CGRectGetHeight(rect),CGRectGetWidth(rect));
	border /= 60;
	
	//Now add the photo as a sublayer, which will be a little smaller than the original rect, to leave room for a border
	innerPhoto = [[CALayer alloc] init];
    innerPhoto.contents = (id) image;
    innerPhoto.contentsGravity = @"resize";
    innerPhoto.minificationFilter = kCAFilterLinear;
    innerPhoto.bounds = CGRectInset(rect,border, border);
	CGPoint innerPos = CGPointMake( CGRectGetMidX(rect), CGRectGetMidY(rect));
	innerPhoto.position = innerPos;
	[self addSublayer: innerPhoto];
	
	self.borderWidth = border;
	self.borderColor = CGColorGetConstantColor(kCGColorWhite);
	CGColorRef background =  CGColorGetConstantColor(kCGColorBlack);
	background = CGColorCreateCopyWithAlpha(background,0.8);
	self.backgroundColor = background;
//	CGFloat scaleOffset = 1 / [[self.superlayer valueForKeyPath:@"transform.scale"] floatValue];
//	CGSize shadowOffset = CGSizeMake( 1.0 * scaleOffset, -3.0 * scaleOffset);
//	self.shadowOffset = shadowOffset;
	//self.shadowOpacity = 1.0;
}

@end
