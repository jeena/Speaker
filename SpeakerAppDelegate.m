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
		[self stopSpeaking];
	} else {
		[self startSpeaking];
	}
}

-(void)stopSpeaking {
	[synth pauseSpeakingAtBoundary:NSSpeechWordBoundary];
	[textView setEditable:YES];
}

-(void)startSpeaking {
	
	[textView setEditable:NO];
	
	NSRange range = [textView selectedRange];
	
	if (range.location == [[[textView textStorage] string] length]) {
		range.location = 0;
		[textView setSelectedRange:NSMakeRange(0,0)];
		[textView scrollRangeToVisible:NSMakeRange(0,0)];
	}
	
	NSString *wholeText = [[textView textStorage] string];
	NSString *text = nil;
	
	if (range.length > 0) { // selection
		text = [wholeText substringWithRange:range];
	} else { // only pointer
		text = [wholeText substringWithRange:NSMakeRange(range.location, [wholeText length] - range.location)];
	}
	
	[synth startSpeakingString:text];
	
	oldRange = range;
	
}

-(IBAction)seekForward:(id)sender {
	// not working yet
	
	[self stopSpeaking];
	
	NSRange selected = [textView selectedRange];
	NSString *wholeText = [[textView textStorage] string];
	NSRange position = [wholeText rangeOfString:@". " options:NSLiteralSearch range:NSMakeRange(selected.location + 1, [wholeText length] - selected.location - 1)];
	[textView setSelectedRange:NSMakeRange(position.location + 2, 0)];

	[self startSpeaking];
}

-(IBAction)seekBack:(id)sender {

}

- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender willSpeakWord:(NSRange)wordToSpeak ofString:(NSString *)text {
	NSRange range = NSMakeRange(oldRange.location + wordToSpeak.location, wordToSpeak.length);
	[textView scrollRangeToVisible:range];
	[textView setSelectedRange:NSMakeRange(range.location, 0)];
	[textView showFindIndicatorForRange:range];
	[textView display];
}

- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender didFinishSpeaking:(BOOL)success {
    [textView setEditable:YES];
}

- (void)dealloc {
	[synth release];
	[super dealloc];
}

@end
