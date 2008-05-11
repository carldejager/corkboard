//
//  CBPhoto.m
//  Multitouch
//
//  Created by Bridger Maxwell on 1/5/08.
//  Copyright 2008 Fiery Ferret. All rights reserved.
//

#import "CBComic.h"
#import "QuartzUtils.h"

@implementation CBComic

- (id) initWithComic: (ComicRef)comic bounds: (CGRect)rect position: (CGPoint)pos;
{
    self = [super init];
    if (self != nil) {
		self.position = pos;
		
        [self setComic: comic bounds: rect];
    }
    return self;
}

- (void) setComic: (ComicRef)comic bounds: (CGRect)rect
{
	self.bounds = rect;
	CGFloat border = MAX(CGRectGetHeight(rect),CGRectGetWidth(rect));
	border /= 60;
	
	//Now add the photo as a sublayer, which will be a little smaller than the original rect, to leave room for a border
	innerPhoto = [[CALayer alloc] init];
    innerPhoto.contents = (id) comic.image;
    innerPhoto.contentsGravity = @"resize";
    innerPhoto.minificationFilter = kCAFilterLinear;
    innerPhoto.bounds = CGRectInset(rect,border, border);
	CGPoint innerPos = CGPointMake( CGRectGetMidX(rect), CGRectGetMidY(rect));
	innerPhoto.position = innerPos;
	[self addSublayer: innerPhoto];
	
	//The following is commented for killing performance (and small children!)
	self.borderWidth = border;
	self.borderColor = CGColorGetConstantColor(kCGColorWhite);
//	CGColorRef background =  CGColorGetConstantColor(kCGColorBlack);
//	background = CGColorCreateCopyWithAlpha(background,0.8);
//	self.backgroundColor = background;
//	self.shadowOpacity = 1.0;

//	CGFloat scaleOffset = 1 / [[self.superlayer valueForKeyPath:@"transform.scale"] floatValue];
//	CGSize shadowOffset = CGSizeMake( 1.0 * scaleOffset, -3.0 * scaleOffset);
//	self.shadowOffset = shadowOffset;
}
				
@end
