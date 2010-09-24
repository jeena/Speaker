//
//  SpeakerAppDelegate.m
//  Speaker
//
//  Created by Jeena on 24.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SpeakerAppDelegate.h"

@implementation SpeakerAppDelegate

@synthesize window, textView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	synth = [[NSSpeechSynthesizer alloc] init];
	oldRange = NSMakeRange(-1, -1);
}

-(IBAction)speakAction:(id)sender {

	if ([synth isSpeaking]) {
		
		[synth pauseSpeakingAtBoundary:NSSpeechWordBoundary];
		
	} else {
		NSRange range = [textView selectedRange];

		if (range.location == [[[textView textStorage] string] length]) {
			range.location = 0;
			[textView setSelectedRange:NSMakeRange(0,0)];
			[textView scrollRangeToVisible:NSMakeRange(0,0)];
		}
		
		if (range.length != oldRange.length || range.location != oldRange.location) {
			NSString *wholeText = [[textView textStorage] string];
			NSString *text = nil;
			
			if (range.length > 0) { // selection
				text = [wholeText substringWithRange:range];
			} else { // only pointer
				text = [wholeText substringWithRange:NSMakeRange(range.location, [wholeText length] - range.location)];
			}
			
			[synth startSpeakingString:text];
			
			oldRange = range;

		} else {

			[synth continueSpeaking];
			
		}
	}

}

@end
