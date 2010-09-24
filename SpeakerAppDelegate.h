//
//  SpeakerAppDelegate.h
//  Speaker
//
//  Created by Jeena on 24.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SpeakerAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	NSTextView *textView;
	NSSpeechSynthesizer *synth;
	NSRange oldRange;
}

@property (assign) IBOutlet NSWindow *window;
@property (retain, nonatomic) IBOutlet NSTextView *textView;

-(IBAction)speakAction:(id)sender;

@end
