//
//  SpeakerApplication.m
//  Speaker
//
//  Created by Jeena on 17.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

// from http://www.rogueamoeba.com/utm/2007/09/29/

#import "SpeakerApplication.h"
#import <IOKit/hidsystem/ev_keymap.h>
#import "SpeakerAppDelegate.h"


@implementation SpeakerApplication

- (void)sendEvent:(NSEvent *)event
{
    // Catch media key events
    if ([event type] == NSSystemDefined && [event subtype] == 8)
    {
        int keyCode = (([event data1] & 0xFFFF0000) >> 16);
        int keyFlags = ([event data1] & 0x0000FFFF);
        int keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA;
		
        // Process the media key event and return
        [self mediaKeyEvent:keyCode state:keyState];
        return;
    }
	
    // Continue on to super
    [super sendEvent:event];
}

- (void)mediaKeyEvent:(int)key state:(BOOL)state
{
    switch (key)
    {
			// Play pressed
        case NX_KEYTYPE_PLAY:
            if (state == NO)
                [(SpeakerAppDelegate *)[self delegate] speakAction:self];
            break;
			
			// Rewind
        case NX_KEYTYPE_FAST:
            if (state == YES)
                [(SpeakerAppDelegate *)[self delegate] seekForward:self];
            break;
			
			// Previous
        case NX_KEYTYPE_REWIND:
            if (state == YES)
                [(SpeakerAppDelegate *)[self delegate] seekBack:self];
            break;
    }
}

@end
