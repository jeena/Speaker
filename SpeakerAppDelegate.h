//
//  SpeakerAppDelegate.h
//  Speaker
//
//  Created by Jeena on 24.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SpeakerAppDelegate : NSObject <NSApplicationDelegate, NSSpeechSynthesizerDelegate> {
    NSWindow *window;
	NSTextView *textView;
    NSMenu *languageMenu;
    NSPopUpButton *languageMenuPopupButton;
	NSSpeechSynthesizer *synth;
	NSRange oldRange;
	BOOL isNewLocation;
}

@property (assign) IBOutlet NSWindow *window;
@property (retain, nonatomic) IBOutlet NSTextView *textView;
@property (assign) IBOutlet NSMenu *languageMenu;
@property (assign) IBOutlet NSPopUpButton *languageMenuPopupButton;

-(IBAction)speakAction:(id)sender;
-(IBAction)seekForward:(id)sender;
-(IBAction)seekBack:(id)sender;

-(void)stopSpeaking;
-(void)startSpeaking;

- (void)changeLanguage:(id)sender;
- (void)changeVoiceGender:(id)sender;

@end
