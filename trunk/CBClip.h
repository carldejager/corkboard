//
//  CBClip.h
//  Multitouch
//
//  Created by Bridger Maxwell on 1/15/08.
//  Copyright 2008 Fiery Ferret. All rights reserved.
//

#import "Bit.h"
#import <QTKit/QTKit.h>

@interface CBClip : Bit {
    QTMovie			*mQTMovie;		// the movie in its QTKit representation
    QTMovieLayer	*innerMovie;
}

- (id) initWithMovie: (QTMovie*)movie bounds: (CGRect)rect position: (CGPoint)pos;

- (void) setMovie: (QTMovie*)movie bounds: (CGRect)rect;

@end
