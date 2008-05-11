//
//  AppController.h
//  Multitouch
//
//  Created by Bridger Maxwell on 1/7/08.
//  Copyright 2008 Fiery Ferret. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppController : NSObject {
	IBOutlet id scaleLabel;
}

- (IBAction) adjustScale: sender;

@end
