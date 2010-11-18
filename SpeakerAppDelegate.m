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
	synth.delegate = self;
	oldRange = NSMakeRange(-1, -1);
	isNewLocation = YES;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *string = [defaults objectForKey:@"text"];
	if (string) {
		NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string];
		[[textView textStorage] setAttributedString:attributedString];
		[attributedString release];
		NSRange aRange = NSMakeRange([defaults integerForKey:@"startLocation"], 0);
		[textView setSelectedRange:aRange];
		[textView scrollRangeToVisible:aRange];
	}
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:[textView selectedRange].location forKey:@"startLocation"];
	[defaults setObject:[[textView textStorage] string] forKey:@"text"];
	[defaults synchronize];
}

-(IBAction)speakAction:(id)sender {
	if ([synth isSpeaking]) {
		
		[synth pauseSpeakingAtBoundary:NSSpeechWordBoundary];
		[textView setEditable:YES];
		
	} else {
		
		[textView setEditable:NO];
		
		NSRange range = [textView selectedRange];

		if (range.location == [[[textView textStorage] string] length]) {
			range.location = 0;
			[textView setSelectedRange:NSMakeRange(0,0)];
			[textView scrollRangeToVisible:NSMakeRange(0,0)];
		}
		
		if (range.length != oldRange.length || range.location != oldRange.location || isNewLocation) {
			isNewLocation = NO;
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

-(IBAction)seekForward:(id)sender {
	// not working yet
	/*
	[self speakAction:self];
	NSRange selected = [textView selectedRange];
	NSString *wholeText = [[textView textStorage] string];
	NSRange position = [wholeText rangeOfString:@". " options:NSLiteralSearch range:NSMakeRange(selected.location + 1, [wholeText length] - selected.location - 1)];
	[textView setSelectedRange:NSMakeRange(position.location + 2, 0)];
	isNewLocation = YES;
	NSLog(@"sp %i", [synth isSpeaking]);
	[self speakAction:self];
	 */
}

-(IBAction)seekBack:(id)sender {

}

- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender willSpeakWord:(NSRange)wordToSpeak ofString:(NSString *)text {
	NSRange range = NSMakeRange(oldRange.location + wordToSpeak.location, wordToSpeak.length);
	[textView scrollRangeToVisible:range];
	[textView setSelectedRange:NSMakeRange(range.location, 0)];
	[textView showFindIndicatorForRange:range];
}

- (void)dealloc {
	[synth release];
	[super dealloc];
}

@end
