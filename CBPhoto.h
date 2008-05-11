//
//  CBPhoto.h
//  Multitouch
//
//  Created by Bridger Maxwell on 1/5/08.
//  Copyright 2008 Fiery Ferret. All rights reserved.
//

#import "Bit.h"

@interface CBPhoto : Bit {
	CALayer * innerPhoto;
}

- (id) initWithImage: (CGImageRef)image bounds: (CGRect)rect position: (CGPoint)pos;

- (void) setImage: (CGImageRef)image bounds: (CGRect)rect;

@end
