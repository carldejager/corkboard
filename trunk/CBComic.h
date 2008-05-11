//
//  CBPhoto.h
//  Multitouch
//
//  Created by Bridger Maxwell on 1/5/08.
//  Copyright 2008 Fiery Ferret. All rights reserved.
//

#import "Bit.h"

typedef struct _comicRef
{
	CGImageRef image;
	int number;
	NSString* name;
	NSString* titleText;
	NSArray* tags;
} ComicRef;

@interface CBComic : Bit {
	CALayer * innerPhoto;
}

- (id) initWithComic: (ComicRef)image bounds: (CGRect)rect position: (CGPoint)pos;
- (void) setComic: (ComicRef)comic bounds: (CGRect)rect;

@end
