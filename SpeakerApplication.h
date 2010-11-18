//
//  SpeakerApplication.h
//  Speaker
//
//  Created by Jeena on 17.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SpeakerApplication : NSApplication {

}

- (void)mediaKeyEvent:(int)key state:(BOOL)state;

@end
